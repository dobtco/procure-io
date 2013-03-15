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

  addOverlay: ->
    @$overlayDiv = $("<div class='dobttour-overlay'></div>")
    @$overlayDiv.css
      width: $(document.body).width()
      height: $(document.body).height()
      top: 0
      left: 0

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

    setTimeout =>
      @$helperLayerDiv.find(".dobttour-tooltip").css
        opacity: 1
        bottom: -(@$helperLayerDiv.find(".dobttour-tooltip").outerHeight() + 10)
    , 100

  showCurrentStep: ->
    step = @steps[@currentStep]

    if typeof step['el'] == 'function'
      $el = step['el']().slice(0, 1)
    else
      $el = $(step['el']).slice(0, 1)

    if $el.length == 0 then @nextStep()

    @setHelperLayer($el, step['text'])
    $el.addClass('dobttour-showElement')

    if !@steps[@currentStep + 1]?
      @$helperLayerDiv.find(".dobttour-nextbutton").text("Done!")

  nextStep: ->
    $(".dobttour-showElement").removeClass("dobttour-showElement")
    @endTour() unless @steps[@currentStep + 1]
    @currentStep++
    @showCurrentStep()

  endTour: ->
    $(".dobttour-showElement").removeClass("dobttour-showElement")
    @$helperLayerDiv.remove()

    @$overlayDiv.fadeOut 100, ->
      $(@).remove()

