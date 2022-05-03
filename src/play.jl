using Revise, Interact, Blink, CSSUtil, LibSerialPort
import Dates.today, Dates.Date
include("StimulationStructure.jl")
##
high = (12,5,0,10)
low = (4,60,0,0)
mixed = (12,5,4,10)
s1 = [high,low,mixed,low,high,mixed]
s2 = [high,low,mixed,low,mixed,high]
s3 = [low,high,mixed,high,low,mixed]
s4 = [mixed,high,low,high,mixed,low]
##
f = FreqStruct(s1)
s = SessionStruct()
es = ExpStruct(f,s,60,30)
es.Frequencies = FreqStruct(s1)
es.Session = SessionStruct("test",24,"COM4")
##
function Widgets.widget(s::SessionStruct)
	p = button("Prepare task")
        m = textbox(value = "test")
        w = spinbox([1,700]; value = 25)
        d = widget(today())
	f = textbox(value = default_dir)
        a = autocomplete(get_port_list(); value ="chose a port")

        output = Observable{SessionStruct}(SessionStruct(missing))

	Interact.@map! output begin
		&p
	        SessionStruct(&m,&w,&d, &f, &a)
	end

        wdg = Widget{:Session_attributes}(
                OrderedDict(
                        :MouseID => m,
                        :Weight => w,
                        :Day => d,
                        :Arduino => a,
			:Prepare => p),
                output = output)

        @layout! wdg vbox(vskip(1em),
		hbox(:MouseID,hskip(1em), :Weight),
		hbox(:Day,hskip(1em),:Arduino),
		:Prepare)
end
##

w_ses = widget(s)
w_ses[]
