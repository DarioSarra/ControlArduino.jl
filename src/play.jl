using Revise, ControlArduino
##
ArduinosController
ControlArduino.
high = (12,5,0,10)
low = (4,60,0,0)
mixed = (12,5,4,10)
s1 = [high,low,mixed,low,high,mixed]
s2 = [high,low,mixed,low,mixed,high]
s3 = [low,high,mixed,high,low,mixed]
s4 = [mixed,high,low,high,mixed,low]
##
import Dates.today
FreqStruct(s1)
SessionStruct()
es = ExpStruct()
es.Frequencies = FreqStruct(s1)
es.Session = SessionStruct("test",24,"COM4")
##
using Interact, Blink, CSSUtil, LibSerialPort
import Dates.today

m = textbox(value="test")
m[]

function Widgets.widget(s::SessionStruct)
	p = button("Prepare task")
        m = textbox(value = s.MouseID)
        w = spinbox([1,700]; value = 25)
        d = widget(Dates.today())
	f = textbox(value = s.Directory)
        a = autocomplete(get_port_list())

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
			:Prepare => p
                        )
                )

        @layout! wdg vbox(
		hbox(1em,:MouseID, 1em, :Weight),1em,
		hbox(1em,:Day,1em,:Arduino), 1em,
		:Prepare)
end
a = autocomplete(get_port_list())
w = spinbox([1,700]; value = 25)
w[]
d = widget(today())
d[]
typeof(today())
isdir(ControlArduino.default_dir)

ports_available = get_port_list()
