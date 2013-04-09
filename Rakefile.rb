def name()
    "kingdom"
end

def versioned_name()
    "#{name}-#{version}"
end

def version()
    %x[cat #{Rake.original_dir}/VERSION].strip
end

def builddir()
    "build"
end

def lovefile()
    "#{versioned_name}.love"
end

def distdir(dist)
    "#{builddir}/#{dist.to_s}"
end

def lovedir(os)
    if os == :osx
        "#{distdir os}/love.app"
    elsif os == :win
        "#{distdir os}/love-0.8.0-win-x86"
    else
        raise "Unknown os: #{os.inspect}"
    end
end

def appfile()
    "#{versioned_name}.app"
end

def exefile()
    "#{versioned_name}.exe"
end

def love_url(os)
    if os == :osx
        "https://bitbucket.org/rude/love/downloads/love-0.8.0-macosx-ub.zip"
    elsif os == :win
        "https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.zip"
    else
        raise "Unknown os: #{os.inspect}"
    end
end

def upload(filename)
    require 'cloudfiles'
    require 'creds'

    cf = CloudFiles::Connection.new(:username => RACKSPACE_USER,
                                    :api_key  => RACKSPACE_API_KEY)
    container = cf.container('games')
    object = container.create_object File.basename(filename), false
    object.load_from_filename filename
    puts "Published #{filename} to #{object.public_url}"
    object
end

directory builddir
directory distdir(:osx)
directory distdir(:win)

desc 'Initialize and update the submodule dependencies'
task :submodules do
    sh "git submodule update --init"
end

namespace :src do
    desc 'Compile a .love file'
    task :dist => [:submodules, builddir] do
        sh <<-EOS
            OUTPUT=#{builddir}/#{lovefile}
            rm -f $OUTPUT
            zip -r $OUTPUT * --exclude \\*.acorn #{builddir}/\\* \\*/.\\* creds.rb
        EOS
    end

    desc 'Compile and publish a .love file to the CDN'
    task :publish => [:dist] do
        upload "#{builddir}/#{lovefile}"
    end
end

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

desc 'Clean out the build directory'
task :clean do
    sh "rm -rf #{builddir}/*"
end

task :default => ["src:dist"]
