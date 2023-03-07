function Widgets.widget(e::ExpStruct)
	f = widget(e.Frequencies)
	s = widget(e.Session)
	pre_s = ismissing(e.StimulatedVolumes) ? 0 : e.PreStimVolumes
	in_s = ismissing(e.StimulatedVolumes) ? 0 : e.InStimVolumes
	post_s = ismissing(e.UnstimulatedVolumes) ? 0 : e.PostStimVolumes
	sv = ismissing(e.StimulatedVolumes) ? 0 : e.StimulatedVolumes
	uv = ismissing(e.UnstimulatedVolumes) ? 0 : e.UnstimulatedVolumes

	pre_stim = labeled_widget("Volumes to wait before stimulation",spinbox,value = pre_s)
	in_stim = labeled_widget("Volumes to stimulate with parameters below",spinbox,value = in_s)
	post_stim = labeled_widget("Volumes not to stimulate in the end",spinbox,value = post_s)
	stim_vol = labeled_widget("Number of volumes with stimulation",spinbox,value = sv)
	unstim_vol = labeled_widget("Number of volumes without stimulation",spinbox,value = uv)
	o = Observable{ExpStruct}(e)
	coll = button("Prepare Experiment")
	start_b = button("Start Experiment")
	stop_b = button("Stop Experiment")


	Interact.@map! o  begin
		&coll
		ExpStruct(f[], s[], pre_stim[], in_stim[], post_stim[], stim_vol[], unstim_vol[])
	end

	Interact.@on begin
        &start_b
		ex = o[]
		Ard = ex.Session.Arduino
		prestimvolumes = ex.PreStimVolumes
		instimvolumes = ex.InStimVolumes
		poststimvolumes = ex.PostStimVolumes
	    stimvolumes = ex.StimulatedVolumes
	    unstimvolumes = ex.UnstimulatedVolumes
	    stimulations = ex.Frequencies.Stimulations
	    stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
	    stimdur1 = rm_missing(ex.Frequencies.Volumes1)
	    stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
	    stimdur2= rm_missing(ex.Frequencies.Volumes2)
		maskled = rm_missing(ex.Frequencies.MaskLed)
	    filename = ex.Session.FileName
		running!(ex.Session.Arduino,true)
		println("spawning at 2")
        task = @async @spawnat 2 run_opto(Ard,
			prestimvolumes, instimvolumes, poststimvolumes,
	        stimvolumes, unstimvolumes, stimulations,
	        stimfreq1,stimdur1,
	        stimfreq2,stimdur2,
			maskled,
	        filename)
    end

	Interact.@on begin
        &stop_b
		running!(o[].Session.Arduino,false)
    end

	d = OrderedDict{Any,Any}(
		:Frequencies => f,
		:Session => s,
		:PreStim => pre_stim,
		:InStim => in_stim,
		:PostStim => post_stim, 
		:StimulatedVolumes => stim_vol,
		:UnstimulatedVolumes => unstim_vol,
		:Collect => coll,
		:Start => start_b,
		:Stop => stop_b
		)

	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w hbox(hskip(1em),
					vbox(
					vskip(1em),
					:Session,
					vskip(1em),
					:Frequencies,
					vskip(2em),
					hbox(:PreStim,hskip(1em), :InStim, hskip(1em), :PostStim),
					vskip(1em),
					hbox(:StimulatedVolumes,hskip(1em),:UnstimulatedVolumes),
					vskip(1em),
					hbox(:Collect,hskip(1em),:Start,hskip(1em),:Stop),
					),
					hskip(1em)
					)

end
