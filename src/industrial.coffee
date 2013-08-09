#*********************************************************************************
#*  Industrial.js -- A jQuery plugin of CSS3 gauges, tanks, and more.
#*  Copyright (c) 2013 Andy J. Brennan
#*
#*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
#*  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
#*  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#*  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
#*  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#*  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#*********************************************************************************

(($) ->

    class Controller
        constructor: (element,@options) ->
            @$element = $(element)
            @value = @options.default_value
        setValue: (val) ->
            @value = val
        getValue: () ->
            return @value

    class BooleanController extends Controller
        constructor: (element,options) ->
            super
            @value = Boolean @value

    class NumericController extends Controller
        constructor: (element,options) ->
            super
            @value = Number @value
            @scale_hi = @options.high
            @scale_low = @options.low
            @tick_amt = @options.tick_amount
            @tick_scale_frequency = @options.tick_scale_frequency
            @tick_scale = @options.tick_scale

        calcDist: (amt, height) ->
            aspect = this.$element.children(".ticks").height() / this.$element.children(".ticks").width()
            return ((100 - height * (amt - 1)) / (amt - 1)) * aspect

    class StringController extends Controller
        constructor: (element,options) ->
            super
            @value = String @value

    class LEDController extends BooleanController
        setValue: (val) ->
            super
            @$element.children(".meter").toggleClass("off", !val)
            return this

    class TankController extends NumericController
        constructor: (element,options) ->
            super
            @tick_height = @options.tick_height
            $ticks = @$element.children(".ticks")
            if $ticks.length <= 0
                return
            tickHeight = 3
            generateTicks = true
            generateScales = true
            tickAmt = 0

            if @tick_height != undefined
                tickHeight = @tick_height
            else if $ticks.data('height') != undefined
                tickHeight = $ticks.data('height')

            if $ticks.children(".tick").length >= 2
                generateTicks = false
            else if @tick_amt not in [undefined, 0, 1]
                tickAmt = @tick_amt
            else if $ticks.data('amount') not in [undefined, 0, 1]
                tickAmt = $ticks.data('amount')
            else
                return

            if $ticks.data('scale-freq') not in [undefined, 0]
                scaleFrequency = $ticks.data('scale-freq')
            else if @tick_scale_frequency not in [undefined, 0] and @tick_scale is true
                scaleFrequency = @tick_scale_frequency
            else
                generateScales = false


            if generateTicks
                for i in [1..tickAmt] by 1
                    $ticks.append('<div class="tick"></div>')

            ticks = $ticks.children(".tick")

            ticks.css("height", tickHeight+"%")
            dist = this.calcDist(ticks.length, tickHeight)
            ticks.css("margin-bottom", dist+"%")

            if generateScales
                inc = (@scale_hi - @scale_low) / (tickAmt - 1)
                for i in [0..tickAmt] by scaleFrequency
                    $(ticks[i]).append('<span class="scale">'+Math.floor((tickAmt - i - 1)*inc)+'</span>')

        setValue: (val) ->
            super
            adjusted = 100 - (val/(@scale_hi-@scale_low))*100
            @$element.children(".space").css("height", adjusted+"%")

    class GaugeController extends NumericController
        constructor: (element,options) ->
            super
            @tick_height = @options.tick_height
            $ticks = @$element.children(".ticks")
            if $ticks.length <= 0
                return
            tickHeight = 2.5
            generateTicks = true
            scaleFrequency = 1
            generateScales = true
            tickAmt = 0

            if $ticks.data('height') != undefined
                tickHeight = $ticks.data('height')
            else if @tick_height != undefined
                tickHeight = @tick_height

            if $ticks.children(".tick").length >= 2
                generateTicks = false
            else if $ticks.data('amount') not in [undefined, 0, 1]
                tickAmt = $ticks.data('amount')
            else if @tick_amt not in [undefined, 0, 1]
                tickAmt = @tick_amt
            else
                return

            if $ticks.data('scale-freq') not in [undefined, 0]
                scaleFrequency = $ticks.data('scale-freq')
            else if @tick_scale_frequency not in [undefined, 0] and @tick_scale is true
                scaleFrequency = @tick_scale_frequency
            else
                generateScales = false

            if generateTicks
                for i in [1..tickAmt+1] by 1
                    $ticks.append('<div class="tick"></div>')

            $ticks.children(".tick").css("width", tickHeight+"%")

            ticks = $ticks.children(".tick")
            for i in [1..tickAmt] by 1
                $(ticks[i]).css("top", i * -100 + "%")
                angle = ( (i-1) / (tickAmt-1) ) * 140 - 70
                $(ticks[i]).css({'-webkit-transform': 'rotate('+angle+'deg)', '-moz-transform': 'rotate('+angle+'deg)', '-ms-transform': 'rotate('+angle+'deg)', '-o-transform': 'rotate('+angle+'deg)', 'transform': 'rotate('+angle+'deg)'})
            
            if generateScales
                inc = (@scale_hi - @scale_low) / (tickAmt - 1)
                for i in [1..tickAmt+1] by scaleFrequency
                    $(ticks[i]).append('<span class="scale">'+Math.floor((i-1)*inc)+'</span>')

        setValue: (val) ->
            super
            adjusted = (val/(@scale_hi-@scale_low))*140 - 70
            @$element.children(".meter").css({'-webkit-transform': 'rotate('+adjusted+'deg)', '-moz-transform': 'rotate('+adjusted+'deg)', '-ms-transform': 'rotate('+adjusted+'deg)', '-o-transform': 'rotate('+adjusted+'deg)', 'transform': 'rotate('+adjusted+'deg)'})

    class ReadoutController extends StringController
        constructor: (element,options) ->
            super
            @digit_amount = @options.digit_amount
            $meter = @$element.children(".meter")
            if $meter.length <= 0
                return
            generateDigits = true

            if $meter.children(".digit").length > 0
                generateDigits = false
            else if @digit_amount not in [undefined, 0, 1]
                digitAmt = @digit_amount
            else if $meter.data('digits') not in [undefined, 0, 1]
                digitAmt = $meter.data('digits')
            else
                return

            if generateDigits
                for i in [1..digitAmt] by 1
                    $meter.append('<span class="digit"></span>')

            this.setValue(@value)
            width = $meter.children(".digit").first().width()
            @$element.css("width", width*digitAmt)

        setValue: (val) ->
            super String val
            digits = @$element.find(".meter > .digit")
            for i in [0...digits.length]
                if @value[i] == undefined
                    $(digits[i]).text('')
                $(digits[i]).text(@value[i])

    # Remove preloaders
    $(document).ready ->
        $(".industrial.preloader").remove()

    
    # jQuery plugin
    $.fn.industrial = (option) ->
        @each ->
            $this = $(this)
            data = $this.data("controller")
            options = $.extend({}, $.fn.industrial.defaults, typeof option is "object" and option)
            CtlClass = undefined
            switch $this.attr("class").split(" ")[1]
                when "tank", "thermometer"
                    CtlClass = TankController
                when "gauge"
                    CtlClass = GaugeController
                when "led"
                    CtlClass = LEDController
                when "readout"
                    CtlClass = ReadoutController
                else
                    throw new TypeError("Industrial component class not recognized!")
            $this.data "controller", (data = new CtlClass(this, options))  unless data
            data.setValue option  if typeof option is "number" or typeof option is "boolean" or typeof option is "string"


    $.fn.industrial.defaults =
        default_value: true
        low: 0
        high: 100
        tick_scale: false
        tick_scale_frequency: 1
) jQuery