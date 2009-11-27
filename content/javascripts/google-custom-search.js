var googleCustomSearch = {
  createHiddenField : function(name, value) {
    var field = document.createElement('input');
    field.setAttribute('type', 'hidden');
    field.setAttribute('name', name);
    field.setAttribute('value', value);
    return field;
  },
  addHiddenField : function(form, name, value) {
    var field = this.createHiddenField(name, value);
    form.appendChild(field);
  },
  removeUnnecessaryField : function(form) {
    var elems = form.getElementsByTagName('input');
    for (var i = 0; i < elems.length; i++) {
      var elem = elems[i];
      if (elem.getAttribute('value') == 'site:blog.floehopper.org') {
        elem.parentNode.removeChild(elem);
      }
    };
  },
  setupForm : function(form) {
    form.setAttribute('action', '/search-results.html');
    form.setAttribute('id', 'cse-search-box');
  },
  loadGoogleCustomSearchJavascript : function() {
    var externalScript = document.createElement('script');
    externalScript.setAttribute('type', 'text/javascript');
    externalScript.setAttribute('src', 'http://www.google.com/coop/cse/brand?form=cse-search-box&amp;lang=en');
    document.body.appendChild(externalScript);
  },
  init : function() {
    var searchForm = document.getElementById('searchForm');
    if (searchForm) {
      this.setupForm(searchForm);
      this.removeUnnecessaryField(searchForm);
      this.addHiddenField(searchForm, 'cx', '002281300614015514184:-bsjaspijha');
      this.addHiddenField(searchForm, 'cof', 'FORID:9');
      this.addHiddenField(searchForm, 'ie', 'UTF-8');
      this.loadGoogleCustomSearchJavascript();
    }
  }
}
googleCustomSearch.init();