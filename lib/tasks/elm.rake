namespace :elm do
  desc "make the Elm JS file for Todos"
  task :todos do
    Dir.chdir("app/views/todos/todos") do
      system("elm-make Main.elm --output ../_todos_elm.js")
    end
  end

  desc "make the Elm JS file for Pills"
  task :pills do
    Dir.chdir("app/views/pages/pills") do
      system("elm-make Main.elm --output ../_pills_elm.js")
    end
  end
end
