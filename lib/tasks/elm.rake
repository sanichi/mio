namespace :elm do
  def compile_and_minify(dir, name)
    Dir.chdir(dir) do
      js = "_#{name}.js"
      min = "../_#{name}.min.js"
      if system("elm-make Main.elm --output #{js}")
        File.open(min, "w") do |file|
          file.write(Uglifier.compile(File.read(js)))
        end
        puts "minified to #{min}"
      end
    end
  end

  desc "make and minify the Elm JS file for Todos"
  task :todos do
    compile_and_minify "app/views/todos/elm", "todos_elm"
  end

  desc "make and minify the Elm JS file for Blue PiLL"
  task :pills do
    compile_and_minify "app/views/pages/pills", "pills_elm"
  end
end
