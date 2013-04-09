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

def loveapp(os)
    if os == :osx
        "/Applications/love.app"
    elsif os == :windows
        "/Volumes/BOOTCAMP/Program Files (x86)/LOVE"
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

directory builddir

desc 'Initialize and update the submodule dependencies'
task :submodules do
    sh "git submodule update --init"
end

desc 'Compile a .love file'
task :compile => [:submodules, builddir] do
    sh <<-EOS
        OUTPUT=#{builddir}/#{lovefile}
        rm $OUTPUT
        zip -r $OUTPUT * --exclude \*.acorn #{builddir}/\* \*/.\*
    EOS
end

namespace :osx do
    desc 'Create a standalone OS X .app'
    task :dist => [:compile] do
        sh <<-EOS
            BUILD_DIR=#{builddir}
            OUTPUT_DIR=$BUILDDIR/#{appfile}

            rm -rf ./$OUTPUT_DIR
            cp -r #{loveapp :osx} $BUILD_DIR/
            cp $BUILD_DIR/#{lovefile} $BUILD_DIR/love.app/Contents/Resources/
            cp etc/Info.plist $BUILD_DIR/love.app/Contents/
            mv $BUILD_DIR/love.app $BUILD_DIR/$OUTPUT_DIR
        EOS
    end

    desc 'Create a zipped standalone OS X .app'
    task :zip => [:dist] do
        sh <<-EOS
            OUTPUT=#{versioned_name}-osx.zip

            cd #{builddir}
            rm -f $OUTPUT
            zip -r $OUTPUT #{appfile}
            cd -
        EOS
    end
end

namespace :win do
    desc 'Create a standalone Windows .app'
    task :win => [:compile] do
        sh <<-EOS
            OUTPUT_DIR='#{versioned_name}'
            APP_DIR='#{loveapp :windows}'

            cd #{builddir}
            rm -rf "./$OUTPUT_DIR"
            mkdir -p "$OUTPUT_DIR"
            cat "$APP_DIR/love.exe" '#{lovefile}' > "./$OUTPUT_DIR/#{exefile}"
            cp "$APP_DIR"/*.dll "./$OUTPUT_DIR"
            cd -
        EOS
    end

    desc 'Create a zipped standalone Windows .exe'
    task :win => [:dist] do
        sh <<-EOS
            NAME=#{versioned_name}
            OUTPUT=$NAME-win.zip

            cd #{builddir}
            rm -f $OUTPUT
            zip -r $OUTPUT $NAME
            cd -
        EOS
    end
end

desc 'Compile and publish a .love file to the CDN'
task :publish => [:compile] do
    require 'cloudfiles'
    require 'creds'

    cf = CloudFiles::Connection.new(:username => RACKSPACE_USER,
                                    :api_key  => RACKSPACE_API_KEY)
    container = cf.container('games')
    filename = "#{builddir}/#{lovefile}"
    object = container.create_object File.basename(filename), false
    object.load_from_filename filename
    puts object.public_url
end

desc 'Clean out the build directory'
task :clean do
    sh "rm -rf #{builddir}/*"
end

task :default => [:compile]
