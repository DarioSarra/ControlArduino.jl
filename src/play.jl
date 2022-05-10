using Revise, Interact, Blink, CSSUtil, LibSerialPort
import Dates.today, Dates.Date
include("StimulationStructure.jl")
include("StimProtocols.jl")
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
es
##
w_ses = widget(s); w = Window(); body!(w,w_ses)
w_freq = widget(f); w = Window(); body!(w,w_freq)
w_freq[]
##
w_ex = widget(ExpStruct());w = Window(); body!(w,w_ex)
w_ex[]
##
opts = OrderedDict(
d[]
