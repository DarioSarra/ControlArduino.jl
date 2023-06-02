function Widgets.widget(e::ExpStruct)
	s = widget(e.Session)
	p = widget(e.Periods)
	f = widget(e.Frequencies)
	
	o = Observable{ExpStruct}(e)
	coll = button("Prepare Experiment")
	start_b = button("Start Experiment")
	stop_b = button("Stop Experiment")


	Interact.@map! o  begin
		&coll
		ExpStruct(s[], p[], f[])
	end

	Interact.@on begin
        &start_b
		ex = o[]
		Ard = ex.Session.Arduino
		prestimvolumes = ex.Periods.PreStimVolumes
		instimvolumes = ex.Periods.InStimVolumes
		poststimvolumes = ex.Periods.PostStimVolumes
	    stimvolumes = ex.Periods.StimulatedVolumes
	    unstimvolumes = ex.Periods.UnstimulatedVolumes
	    stimulations = ex.Frequencies.Stimulations
	    stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
	    stimdur1 = rm_missing(ex.Frequencies.Volumes1)
	    stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
	    stimdur2= rm_missing(ex.Frequencies.Volumes2)
	    pulse= rm_missing(ex.Frequencies.Pulse)
		maskled = rm_missing(ex.Frequencies.MaskLed)
	    filename = ex.Session.FileName
		running!(ex.Session.Arduino,true)
		println("spawning at 2")
        task = @async @spawnat 2 run_opto(Ard,
			prestimvolumes, instimvolumes, poststimvolumes,
	        stimvolumes, unstimvolumes, stimulations,
	        stimfreq1,stimdur1,
	        stimfreq2,stimdur2,
			pulse, maskled,
	        filename)
    end

	Interact.@on begin
        &stop_b
		running!(o[].Session.Arduino,false)
    end

	d = OrderedDict{Any,Any}(
		:Frequencies => f,
		:Session => s,
		:Periods => p,
		:Collect => coll,
		:Start => start_b,
		:Stop => stop_b
		)

	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w hbox(hskip(1em),
					vbox(
						vskip(1em),
						"Insert session info to store csv output file",
						:Session,
						vskip(2em),
						:Periods,
						vskip(2em),
						:Frequencies,
						vskip(2em),
						hbox(:Collect,hskip(1em),:Start,hskip(1em),:Stop),
					),
					hskip(1em)
					)

end