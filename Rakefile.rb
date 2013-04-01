def version()
    %x[cat VERSION].strip
end

def lovefile()
    %x[echo build/${PWD##*/}-$(cat VERSION).love].strip
end

directory "build"

desc 'Initialize and update the submodule dependencies'
task :submodules do
    sh "git submodule update --init"
end

desc 'Compile a .love file'
task :compile => [:submodules, "build"] do
    sh <<-EOS
        OUTPUT=#{lovefile}
        rm $OUTPUT
        zip -r $OUTPUT * --exclude \*.acorn build/\* \*/.\*
    EOS
end

desc 'Compile and publish a .love file to the CDN'
task :publish => [:compile] do
    require 'cloudfiles'
    require 'creds'

    cf = CloudFiles::Connection.new(:username => RACKSPACE_USER,
                                    :api_key  => RACKSPACE_API_KEY)
    container = cf.container('games')
    filename = lovefile
    object = container.create_object File.basename(filename), false
    object.load_from_filename filename
    puts object.public_url
end

desc 'Clean out the build directory'
task :clean do
    sh "rm -rf build/*"
end

task :default => [:compile]
