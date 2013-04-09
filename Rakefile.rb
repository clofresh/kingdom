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

namespace :dist do
    desc 'Create a standalone OS X .app'
    task :osx => [:clean, :compile] do
        sh "cp -r #{loveapp :osx} #{builddir}/"
        sh "cp #{builddir}/#{lovefile} #{builddir}/love.app/Contents/Resources/"
        sh "cp etc/Info.plist #{builddir}/love.app/Contents/"
        sh "mv #{builddir}/love.app #{builddir}/#{appfile}"
    end

    desc 'Create a zipped standalone OS X .app'
    task :osx_zipped => [:osx] do
        cd builddir do
            sh "zip -r #{appfile}.zip #{appfile}"
        end
    end

    desc 'Create a standalone Windows .app'
    task :windows => [:clean, :compile] do
        cd builddir do
            sh <<-EOS
                OUTPUT_DIR='#{versioned_name}'
                APP_DIR='#{loveapp :windows}'
                mkdir -p "$OUTPUT_DIR"
                cat "$APP_DIR/love.exe" '#{lovefile}' > "$OUTPUT_DIR/#{exefile}"
                cp "$APP_DIR"/*.dll "$OUTPUT_DIR"
            EOS
        end
    end

    desc 'Create a zipped standalone Windows .exe'
    task :windows_zipped => [:windows] do
        cd builddir do
            sh "zip -r #{versioned_name}.zip #{versioned_name}"
        end
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
