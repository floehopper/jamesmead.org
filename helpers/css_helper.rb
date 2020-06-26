module CssHelper
  def css_class(classes)
    classes ? %(class="#{classes}") : ''
  end
end
