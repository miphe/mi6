
// TODO
// - Add a Jasmine test suite
// - Add goto-link functionality with anchor highlighting
//   => User clicks on link that goes to #anchor
//   => User is taken to that page and is scrolled smoothly to that anchor
//   => The anchor element should highlight and fade off.

(function($) {

  Magnific = function(type, selector) {
    this.init = function() {
      var $objs = $(selector);
      var settings = {
        "type": type,
        "closeOnContentClick": true,
        "gallery": {
          "enabled": false
        }
      };

      if ($objs.length > 1) {
        settings.closeOnContentClick = false;
        settings.gallery.enabled = true;
      }

      $objs.magnificPopup(settings);
    }
  }

  ExperienceGraph = function(selector) {
    this.init = function() {
      var $module = $(selector).first();
      $nav = typeof nav === 'undefined' ? $module.find('ul').first() : $module.find(nav).first();

      this.module = $module;
      this.nav = $nav;
      this.applyNavListener();
      this.applySubjectListener();

      // Initial load
      this.module.trigger('subject-change', this.nav.find('li').first());
    }

    this.clearOldGraphData = function() {
      var $kn = this.module.find('.bar-knowledge');
      var $xp = this.module.find('.bar-experience');
      var $ps = this.module.find('.bar-passion');
      var $cn = this.module.find('.subject-content');

      // Removing unecessary classes
      $kn.attr('class', 'bar-knowledge');
      $xp.attr('class', 'bar-experience');
      $ps.attr('class', 'bar-passion');
      $cn.empty();
    }

    this.applyNewGraphData = function(element) {
      data = this.gatherData(element);
      var $kn = this.module.find('.bar-knowledge');
      var $xp = this.module.find('.bar-experience');
      var $ps = this.module.find('.bar-passion');
      var $cn = this.module.find('.subject-content');

      var $preContent = $('<em>' + data.label + ' ::</em>')

      $kn.addClass('filled-' + data.kn);
      $xp.addClass('filled-' + data.xp);
      $ps.addClass('filled-' + data.ps);
      $cn.text(data.content).prepend($preContent);
      $cn.wrapInner('<p></p>');
    }

    this.applySubjectListener = function() {
      t = this;
      this.module.on('subject-change', function(e, listItem) {
        t.clearOldGraphData();
        t.applyNewGraphData(listItem);
      })
    }

    this.applyNavListener = function() {
      t = this;
      this.nav.on('click', 'a', function(e) {
        e.preventDefault();
        t.nav.find('a').removeClass('is-active');
        $(this).toggleClass('is-active');

        t.module.trigger('subject-change', $(this).closest('li'));
      })
    }

    this.gatherData = function(listItem) {
      return $(listItem).data('subject');
    }
  }

  var magnImageHandler = new Magnific('image', '.viewable-image');
  magnImageHandler.init();

  var xpGraphModule = new ExperienceGraph('.xp-graph');
  xpGraphModule.init();

})(jQuery);
