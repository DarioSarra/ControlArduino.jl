using Revise, Interact, Blink, CSSUtil, LibSerialPort
import Dates.today, Dates.Date
include("StimulationStructure.jl")
include("StimProtocols.jl")
include("ExpWidgets.jl")
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
##
w_ex = widget(es);w = Window(); body!(w,w_ex)
w_ex[:Freq_vals][][1][:f1][]
w_ex[]
##
opts = OrderedDict(
d[]
##
opts = labeled_widget("Premade Stim",dropdown, val = OrderedDict(
    "Stim_1" => [high,low,mixed,low,high,mixed],
    "Stim_2" => [high,low,mixed,low,mixed,high],
    "Stim_3" => [low,high,mixed,high,low,mixed],
    "Stim_4" => [mixed,high,low,high,mixed,low]
))
FreqStruct(opts[])
##
f = FreqStruct(s1)
wt = tabulator(OrderedDict("1" => widget(f), "2" => widget(FreqStruct())));
w = Window(); body!(w,wt)
wt[]
