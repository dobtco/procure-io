class window.DobtTour
  constructor: (steps) ->
    @steps = steps
    @currentStep = 0
    return unless @steps.length > 0
    @start()

  start: ->
    @addOverlay()
    @addHelperLayer()
    @showCurrentStep()
    $(document).on "keydown", (e) =>
      @keydown(e)

  keydown: (e) ->
    switch e.keyCode
      when 27 then @endTour()
      when 37 then @previousStep()
      when 39 then @nextStep()

  addOverlay: ->
    @$overlayDiv = $("<div class='dobttour-overlay'></div>")

    @$overlayDiv.on "click", =>
      @endTour()

    @$overlayDiv.appendTo("body")

    @$overlayDiv.animate
      opacity: 0.5
    , 10

  addHelperLayer: ->
    @$helperLayerDiv = $("""
      <div class="dobttour-helperLayer">
        <span class="dobttour-helperNumberLayer"></span>
        <div class="dobttour-tooltip">
          <div class="dobttour-tooltiptext"></div>
          <div class="dobttour-tooltipbuttons">
            <a class="dobttour-skipbutton">Skip</a>
            <a class="dobttour-nextbutton">Next →</a>
          </div>
        </div>
      </div>
    """)

    @$helperLayerDiv.on "click", ".dobttour-nextbutton", =>
      @nextStep()

    @$helperLayerDiv.on "click", ".dobttour-skipbutton", =>
      @endTour()

    @$helperLayerDiv.appendTo("body")

  setHelperLayer: ($el, text) ->
    @$helperLayerDiv.css
      width: $el.outerWidth() + 10
      height: $el.outerHeight() + 10
      top: $el.offset().top - 5
      left: $el.offset().left - 5

    @$helperLayerDiv.find(".dobttour-helperNumberLayer").text(@currentStep + 1)
    @$helperLayerDiv.find(".dobttour-tooltiptext").text(text)
    @$helperLayerDiv.find(".dobttour-tooltip").css({opacity: 0})

    $tooltipClone = @$helperLayerDiv.find(".dobttour-tooltip").clone().appendTo("body").css({"transition": "none"}).css({"width":$el.outerWidth() + 10})
    height = $tooltipClone.outerHeight()
    $tooltipClone.remove()

    @$helperLayerDiv.find(".dobttour-tooltip").css
      opacity: 1
      bottom: -(height + 10)

  showCurrentStep: ->
    step = @steps[@currentStep]

    if typeof step['el'] == 'function'
      $el = step['el']().slice(0, 1)
    else
      $el = $(step['el']).slice(0, 1)

    if $el.length == 0 then @nextStep()

    @setHelperLayer($el, step['text'])
    setTimeout =>
      $el.addClass('dobttour-showElement')
    , 200

    if !@steps[@currentStep + 1]?
      @$helperLayerDiv.find(".dobttour-nextbutton").text("Done!")

  previousStep: ->
    @changeStep(-1)

  nextStep: ->
    @changeStep(1)

  changeStep: (delta) ->
    $(".dobttour-showElement").removeClass("dobttour-showElement")
    return @endTour() unless @steps[@currentStep + delta]?
    @currentStep = @currentStep + delta
    @showCurrentStep()

  endTour: ->
    $(".dobttour-showElement").removeClass("dobttour-showElement")
    @$helperLayerDiv.remove()

    @$overlayDiv.fadeOut 100, ->
      $(@).remove()

    $(document).off "keydown", @keydown
