directory distdir(:osx)

task :osx => ["osx:zip"]
namespace :osx do
    desc 'Downloads and unzips Love.app'
    task :get_love => [distdir(:osx)] do
        sh <<-EOS
            URL=#{love_url :osx}
            FILENAME=$(basename $URL)

            cd #{distdir :osx}
            if [ ! -f $FILENAME ]
            then
                curl -L $URL > $FILENAME
            fi
            if [ ! -d love.app ]
            then
                unzip $FILENAME
            fi
            cd -
        EOS
    end

    desc 'Create a standalone OS X .app'
    task :dist => [:get_love, "src:dist"] do
        sh <<-EOS
            BUILD_DIR=#{builddir}
            DIST_DIR=#{distdir :osx}
            OUTPUT_DIR=$DIST_DIR/#{appfile}

            rm -rf ./$OUTPUT_DIR
            cp -r #{lovedir :osx} $OUTPUT_DIR
            cp $BUILD_DIR/#{lovefile} $OUTPUT_DIR/Contents/Resources/
            cp etc/Info.plist $OUTPUT_DIR/Contents
        EOS
    end

    desc 'Create a zipped standalone OS X .app'
    task :zip => [:dist] do
        sh <<-EOS
            OUTPUT=#{versioned_name}-osx.zip

            cd #{distdir :osx}
            rm -f $OUTPUT
            zip -r $OUTPUT #{appfile}
            cd -
        EOS
    end

    desc 'Compile and publish a zipped standalone OS X .app to the CDN'
    task :publish => [:zip] do
        upload "#{distdir :osx}/#{versioned_name}-osx.zip"
    end
end
