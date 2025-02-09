import "jquery"
import "autocomplete"
import "popper"
import "bootstrap"
import "@hotwired/turbo-rails"
import "controllers"

Turbo.session.drive = false;

import Rails from "@rails/ujs"
Rails.start();
