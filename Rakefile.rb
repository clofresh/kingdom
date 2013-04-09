def name()
    "kingdom"
end

def version()
    %x[cat #{Rake.original_dir}/VERSION].strip
end

def builddir()
    "build"
end

def lovefile()
    "#{name}-#{version}.love"
end

def loveapp()
    "/Applications/love.app"
end

def appfile()
    "#{name}-#{version}.app"
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
        sh "cp -r #{loveapp} #{builddir}/"
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
