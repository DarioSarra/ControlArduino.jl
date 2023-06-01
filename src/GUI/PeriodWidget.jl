function Widgets.widget(p::PeriodStruct)
	pre_s = ismissing(p.StimulatedVolumes) ? 0 : p.PreStimVolumes
	in_s = ismissing(p.StimulatedVolumes) ? 0 : p.InStimVolumes
	post_s = ismissing(p.UnstimulatedVolumes) ? 0 : p.PostStimVolumes
	sv = ismissing(p.StimulatedVolumes) ? 0 : p.StimulatedVolumes
	uv = ismissing(p.UnstimulatedVolumes) ? 0 : p.UnstimulatedVolumes

    pre_stim = labeled_widget("Pre-stimulation period",spinbox,value = pre_s)
	in_stim = labeled_widget("Stimulation period",spinbox,value = in_s)
	post_stim = labeled_widget("Post-stimulation period",spinbox,value = post_s)
	stim_vol = labeled_widget("Repetitions with laser ON in stimulation period",spinbox,value = sv)
	unstim_vol = labeled_widget("Repetitions with laser OFF in stimulation period",spinbox,value = uv)
    ## we need to create an observable variable to edit it with the gui, so we create an observable version of the initial PeriodStruct p 
	o = Observable{PeriodStruct}(p)
	coll = button("Prepare Periods")
   
    Interact.@map! o  begin
		&coll
		PeriodStruct(pre_stim[], in_stim[], post_stim[], stim_vol[], unstim_vol[])
	end

    wdg = Widget{:Periods}(
            OrderedDict(
                    :PreStim => pre_stim,
                    :InStim => in_stim,
                    :PostStim => post_stim,
                    :StimON => stim_vol,
                    :StimOFF => unstim_vol,
                    :Collect => coll
                    ),
            output = o) #the widget needs to map it's output to the observable
    @layout! wdg vbox(
        "Define overall run structure, with # repetitions per period (before, during, and after stimulation)",
        vskip(0.5em),
        hbox(:PreStim,hskip(1em), :InStim, hskip(1em), :PostStim),
        vskip(1em),
        "Define number of repetitions to alternate laser on-off during the stimulation period",
        vskip(0.5em),
        hbox(:StimON,hskip(1em),:StimOFF),
        vskip(0.1em),
        :Collect,
    )
end