using Revise, Interact, Blink, CSSUtil, LibSerialPort
import Dates.today, Dates.Date
include("StimulationStructure.jl")
include("ExpWidgets.jl")
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
w_ses = widget(s);
w = Window(); body!(w,w_ses)
w_ses[]
c = mytextbox("Subject"; value = "test")
c[]
c = myspinbox("Weight in g";value= 25)
datepicker(value = today())
mydatepicker("Day", today())
##
function Widgets.widget(s::FreqStruct)
	p = button("Prepare Session Stimulation")
	s = spinbox(1:10) # number of stimulation types
    m = textbox(value = "test") # Subject ID
    w = spinbox([1,700]; value = 25) # Weight
    d = widget(today()) # Date
	f = textbox(value = default_dir) # Directory
    a = autocomplete(get_port_list(); value ="chose a port") # Serial Port address

	res = Observable{String}("Waiting for input")


	output = Observable{SessionStruct}(SessionStruct(missing))
	Interact.@map! output begin
		&p
	    SessionStruct(m[],w[],d[], f[], a[])
	end

	i = Observable{}(textarea(;value = "Waiting for input", rows = 2))
	function update_res(m,w,s)
		textarea(;value = m*" "*string(w)*"g\n"*s.FileName, rows = 2)
	end

	Interact.@map! i update_res(&m,&w,&output)

	wdg = Widget{:Session_attributes}(
            OrderedDict(
                    :MouseID => m,
                    :Weight => w,
                    :Day => d,
                    :Arduino => a,
					:Info => i,
					:Prepare => p),
            output = output)

	@layout! wdg vbox(vskip(1em),
			hbox(
				vbox(
						hbox(:MouseID,hskip(1em), :Weight),
						vskip(1em),
						hbox(:Day,hskip(1em),:Arduino),
					),
				hskip(1em),
				:Info
				),
			:Prepare
		)
end
##
