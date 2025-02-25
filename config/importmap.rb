pin "application"
pin "jquery", to: "jquery3.min.js"
pin "autocomplete", to: "jquery-ui/widgets/autocomplete.js"
pin "popper", to: "popper.js"
pin "bootstrap", to: "bootstrap.min.js"
pin "elm_aoc", to: "elm_aoc.min.js", preload: false
pin "elm_board", to: "elm_board.min.js", preload: false
pin "elm_play", to: "elm_play.min.js", preload: false
pin "elm_tree", to: "elm_tree.min.js", preload: false
pin "elm_weight", to: "elm_weight.min.js", preload: false
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers", preload: false
