def version()
    %x[cat VERSION].strip
end

directory "build"

task :submodules do
    sh "git submodule update --init"
end

task :compile => [:submodules, "build"] do
    sh <<-EOS
        OUTPUT=build/${PWD##*/}-#{version}.love
        rm $OUTPUT
        zip -r $OUTPUT * --exclude \*.acorn build/\* \*/.\*
    EOS
end

task :clean do
    sh "rm -rf build/*"
end

task :default => [:compile]
