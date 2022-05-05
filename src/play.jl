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
w_ses = widget(s); w = Window(); body!(w,w_ses)
w_freq = widget(f); w = Window(); body!(w,w_freq)

w_ses[]
##
FreqStruct()
c = stim_wid()
c[]
c2 = widget(f);
c2[]
##
function Widgets.widget(f::FreqStruct)
	frequencies = Observable{FreqStruct}(f)
	freq_spins = Observable{Any}(dom"div"())
	freq_n = labeled_widget("Select # of stim protocols between 1 and 10",spinbox;val = (1:10), value = 1)
	map!(t-> dom"div"(stim_wid(t)),freq_spins,freq_n)
	d = OrderedDict(:n => freq_spins, :frequencies => freq_spins)
	o = Observable{FreqStruct}(f)
	Interact.@map! o begin
		FreqStruct(&freq_spins)
	end
	w = Interact.Widget{:Stim_sel}(d, output = o)
	@layout! w vbox(:n,:frequencies)
	return w
end


##
chose_stims()
f
t = widget(f)
##
c = [spinbox() for x in 1:4]
vbox(c)
