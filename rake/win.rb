directory distdir(:win)

task :win => ["win:zip"]
namespace :win do
    desc 'Downloads and unzips love.exe and .dlls'
    task :get_love => [distdir(:win)] do
        sh <<-EOS
            URL=#{love_url :win}
            FILENAME=$(basename $URL)

            cd #{distdir :win}
            if [ ! -f $FILENAME ]
            then
                curl -L $URL > $FILENAME
            fi
            if [ ! -d ${FILENAME%.zip} ]
            then
                unzip $FILENAME
            fi
            cd -
        EOS
    end

    desc 'Create a standalone Windows .app'
    task :dist => [:get_love, "src:dist"] do
        sh <<-EOS
            LOVE_DIR='#{lovedir :win}'
            BUILD_DIR='#{builddir}'
            DIST_DIR='#{distdir :win}'
            OUTPUT_DIR=$DIST_DIR/#{versioned_name}

            rm -rf "./$OUTPUT_DIR"
            mkdir -p "$OUTPUT_DIR"
            cat "$LOVE_DIR/love.exe" "$BUILD_DIR/#{lovefile}" > "./$OUTPUT_DIR/#{exefile}"
            cp "$LOVE_DIR"/*.dll "./$OUTPUT_DIR/"
        EOS
    end

    desc 'Create a zipped standalone Windows .exe'
    task :zip => [:dist] do
        sh <<-EOS
            NAME=#{versioned_name}
            OUTPUT=$NAME-win.zip

            cd #{distdir :win}
            rm -f $OUTPUT
            zip -r $OUTPUT $NAME
            cd -
        EOS
    end

    desc 'Compile and publish a zipped standalone Windows .exe to the CDN'
    task :publish => [:zip] do
        upload "#{distdir :win}/#{versioned_name}-win.zip"
    end
end