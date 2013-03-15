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

    @$overlayDiv.appendTo("body")

    @$overlayDiv.animate
      opacity: 0.5
    , 10

  addHelperLayer: ->
    @$helperLayerDiv = $("""
      <div class="dobttour-helperLayer">
        <span class="dobttour-helperNumberLayer"></span>
        <div class="dobttour-tooltip" style="bottom: -70px;">
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

  moveHelperLayer: ($el) ->
    @$helperLayerDiv.css
      width: $el.width()
      height: $el.height()
      top: $el.position().top
      left: $el.position().left

    @$helperLayerDiv.find(".dobttour-helperNumberLayer").text(@currentStep + 1)

  showCurrentStep: ->
    step = @steps[@currentStep]

    if typeof step['el'] == 'function'
      $el = step['el']()
    else
      $el = $(step['el'])

    @moveHelperLayer($el)
    @$helperLayerDiv.find(".dobttour-tooltiptext").text(step['text'])


  nextStep: ->
    @endTour() unless @steps[@currentStep + 1]
    @currentStep++
    @showCurrentStep()

  endTour: ->
    @$overlayDiv.remove()
    @$helperLayerDiv.remove()