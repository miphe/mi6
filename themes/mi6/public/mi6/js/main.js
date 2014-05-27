
// TODO
// - Add a Jasmine test suite

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
      var $bar_1 = this.module.find('.bar-1');
      var $bar_2 = this.module.find('.bar-2');
      var $bar_3 = this.module.find('.bar-3');
      var $cn = this.module.find('.subject-content');

      // Removing unecessary classes
      $bar_1.attr('class', 'bar-1');
      $bar_2.attr('class', 'bar-2');
      $bar_3.attr('class', 'bar-3');
      $cn.empty();
    }

    this.applyNewGraphData = function(element) {
      data = this.gatherData(element);
      var $bar_1 = this.module.find('.bar-1');
      var $bar_2 = this.module.find('.bar-2');
      var $bar_3 = this.module.find('.bar-3');
      var $cn = this.module.find('.subject-content');

      var $preContent = $('<em>' + data.label + ' ::</em>')

      $bar_1.addClass('filled-' + data.bar_1);
      $bar_2.addClass('filled-' + data.bar_2);
      $bar_3.addClass('filled-' + data.bar_3);
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

  FormHandler = function(selector) {
    this.el = $(selector);

    this.renderMessage = function(html) {
      $('section.feedback-container').html(html);
    }

    this.ajaxSubmission = function(url, data, button) {
      var that = this;
      var button = button || this.el.find('.form-cta');
      var text = button.text();
      var icon = button.find('i');

      var req = $.ajax({
        type:     'POST',
        url:      url,
        data:     data,
        dataType: 'html',
        beforeSend: function() {

          button.prop('disabled', true);

          // Indicated on the submit button that work is in place
          if(button.is('input')){
            button.val('Sending e-mail..');
          } else if (button.is('button')) {
            button.text('Sending e-mail..');
          }
        }
      });

      req.done(function(response, status, xhr){
        // Update the document with feedback
        var content = $(response).find('section.feedback-container').html();
        that.renderMessage(content);
      });

      req.fail(function() {
        console.warn('Ajax failed!');
        var $ajaxError = $('<p class="negative-text">The message could not be sent, this will hopefully be taken care of soon.</p>');
        that.renderMessage($ajaxError);
      });

      req.always(function() {
        // Restores the original state of the submit button
        button.prop('disabled', false);

        if(button.is('input')){
          button.val(text);
        } else if (button.is('button')) {
          button.text(text).append(icon);
        }
      });
    }

    this.init = function() {
      var that = this;

      // Apply light form security
      this.el.find('#name').closest('section').hide();

      // Attach listeners
      this.el.on('submit', function(e) {
        e.preventDefault();
        console.log($(this).attr('action'));
        that.ajaxSubmission($(this).attr('action'), $(this).serialize());
      });
    }
  }

  var magnImageHandler = new Magnific('image', '.viewable-image');
  magnImageHandler.init();

  var xpGraphModule = new ExperienceGraph('.xp-graph');
  xpGraphModule.init();

  var contactForm = new FormHandler('.contact-form');
  contactForm.init();

})(jQuery);
