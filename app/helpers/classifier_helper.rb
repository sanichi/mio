module ClassifierHelper
  def classifier_style(classifier)
    bg, fg = "white", "black"
    if classifier
      bg = "#" + classifier.color
      fg = "white" if classifier.dark?
    end
    "background-color:#{bg}; color:#{fg}"
  end
end
