function Widgets.widget(s::SessionStruct)
	p = button("Prepare Session Info")
	m = labeled_widget("Subject", textbox; value = "test")
	w = labeled_widget("Weight in g", spinbox; value = 25)
	d = labeled_widget("Day", datepicker; value = today())
	folder = isdir(default_dir) ? default_dir : joinpath(@__DIR__,"Outputs")
	f = labeled_widget("Directory", textbox;value = folder)
	a = labeled_widget("Serial Port",dropdown; val = get_port_list())

	res = Observable{String}("Waiting for input")

	output = Observable{SessionStruct}(SessionStruct(missing))
	Interact.@map! output begin
		&p
	    SessionStruct(m[],w[],d[], f[], a[])
	end

	i = Observable{}(labeled_widget("File output",textarea;value = "Waiting for input", rows = 8))
	function update_res(m,w,a,s)
		labeled_widget("File output",textarea;
			value = "Subject: "*m*", "*string(w)*"g\n"*
			"\n Port: "*a* "\n"*
			"\n File name: "*s.FileName, rows = 2)
	end

	Interact.@map! i update_res(&m,&w,&a,&output)

	wdg = Widget{:Session_attributes}(
            OrderedDict(
                    :Subject => m,
                    :Weight => w,
                    :Day => d,
                    :Arduino => a,
					:Directory => f,
					:Info => i,
					:Prepare => p),
            output = output)

	@layout! wdg vbox(vskip(1em),
					hbox(
						vbox(:Subject, vskip(1em),:Day), hskip(1em),
						vbox(:Weight, vskip(1em),:Arduino), hskip(1em),
						vbox(:Directory, vskip(1em), :Info)
						),
					:Prepare
					)
end

function labeled_widget(label, or; val = nothing, kwargs...)
	d = OrderedDict(:label => label, :w => or(val; kwargs...))
	o = map(t->t, d[:w])
	w = Interact.Widget{:labeled}(d, output = o)
	@layout! w vbox(:label, :w)
	return w
end

function single_stim_widget(;freq = (0,0,0,0))
	o = Observable{NTuple}((freq)) #2 paranthesis to indicate the argument is a Tuple
	d = OrderedDict(:f1 => spinbox(value = freq[1]), :v1 => spinbox(value = freq[2]),
		:f2 => spinbox(value = freq[3]), :v2 => spinbox(value = freq[4]))
	Interact.@map! o (&d[:f1], &d[:v1], &d[:f2], &d[:v2])
	w = Interact.Widget{:Stim}(d, output = o)
	@layout! w vbox(
		hbox(hskip(0.5em),"HZ_1",:f1),
		hbox(hskip(0.5em),"Vol_1",:v1),
		hbox(hskip(0.5em),"HZ_2",:f2),
		hbox(hskip(0.5em),"Vol_2",:v2)
		)
	return w
end

function stim_widget(stims::Vector{NTuple{4,Int64}})
	[single_stim_widget(freq = x) for x in stims]
end


function tuple_frequencies(f1::T,v1::T,f2::T,v2::T) where {T <:Vector{Any}}
    all(length(x)== length(f1) for x in [v1,f2,v2]) || error("feeded unequal length arrays")
    res = NTuple[]
    for i in 1:length(f1)
        push!(res,(f1[i],v1[i],f2[i],v2[i]))
    end
    res
end

function tuple_frequencies(f1::T,v1::T,f2::T,v2::T) where {T <:Vector{Union{Missing,Int64}}}
    all(length(x)== length(f1) for x in [v1,f2,v2]) || error("feeded unequal length arrays")
    res = NTuple{4,Int64}[]
    convert_miss(x) = ismissing(x) ? 0 : x
    for i in 1:length(f1)
        push!(res,(convert_miss(f1[i]),convert_miss(v1[i]),
            convert_miss(f2[i]),convert_miss(v2[i])))
    end
    res
end

function Interact.widget(f::FreqStruct)
	stim_n = labeled_widget("Select # of stim protocols between 1 and 10",spinbox;val = (1:10),
		value = f.Stimulations > 0 ? f.Stimulations : 1)
	coll = button("Prepare Stim Frequencies")
	freq_opt = labeled_widget("Premade Stim",dropdown,
		val = OrderedDict(
			"Stim_1" => [high,low,mixed,low,high,mixed],
			"Stim_2" => [high,low,mixed,low,mixed,high],
			"Stim_3" => [low,high,mixed,high,low,mixed],
			"Stim_4" => [mixed,high,low,high,mixed,low]
			)
	)

	stims_layout = Observable{Any}(dom"div"())
	spins = Observable{Any}(stim_widget(tuple_frequencies(f.Frequency1,f.Volumes1,f.Frequency2,f.Volumes2)))
	o = Observable{FreqStruct}(f)

	Interact.@map! spins begin
		&stim_n
		if stim_n[] <= f.Stimulations
			[single_stim_widget(;freq = (f.Frequency1[i],f.Volumes1[i],f.Frequency2[i],f.Volumes2[i])) for i in 1:stim_n[]]
		else
			[single_stim_widget() for i in 1:stim_n[]]
		end
	end

	Interact.@map! spins stim_widget(&freq_opt)

	Interact.@map! stims_layout begin
		&stim_n
		&freq_opt
		vbox("Indicate frequency and # of volumes for stim 1 and 2",vskip(1em),hbox(spins[]...))
	end

	Interact.@map! o begin
		&coll
		FreqStruct([(x[:f1][], x[:v1][],x[:f2][],x[:v2][]) for x in spins[]])
	end

	d = OrderedDict{Any,Any}(
		:Stims => stim_n,
		:Coll => coll,
		:Freq_layout => stims_layout,
		:Freq_vals => spins,
		:Opts => freq_opt
	)
	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w vbox(vskip(1em),
		hbox(stim_n,hskip(1em),:Opts),
		vskip(1em),
		stims_layout,
		vskip(1em),coll)
end


function Widgets.widget(e::ExpStruct)
	f = widget(e.Frequencies)
	s = widget(e.Session)
	sv = ismissing(e.StimulatedVolumes) ? 0 : e.StimulatedVolumes
	uv = ismissing(e.UnstimulatedVolumes) ? 0 : e.UnstimulatedVolumes

	stim_vol = labeled_widget("Number of volumes with stimulation",spinbox,value = sv)
	unstim_vol = labeled_widget("Number of volumes without stimulation",spinbox,value = uv)
	o = Observable{ExpStruct}(e)
	coll = button("Prepare Experiment")
	start_b = button("Start Experiment")
	stop_b = button("Stop Experiment")


	Interact.@map! o  begin
		&coll
		ExpStruct(f[], s[],stim_vol[], unstim_vol[])
	end

	Interact.@on begin
        &start_b
		ex = o[]
		Ard = ex.Session.Arduino
	    stimvolumes = ex.StimulatedVolumes
	    unstimvolumes = ex.UnstimulatedVolumes
	    stimulations = ex.Frequencies.Stimulations
	    stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
	    stimdur1 = rm_missing(ex.Frequencies.Volumes1)
	    stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
	    stimdur2= rm_missing(ex.Frequencies.Volumes2)
	    filename = ex.Session.FileName
		running!(ex.Session.Arduino,true)
		println("spawning at 2")
        task = @async @spawnat 2 run_opto(Ard,
	        stimvolumes, unstimvolumes, stimulations,
	        stimfreq1,stimdur1,
	        stimfreq2,stimdur2,
	        filename)
    end

	Interact.@on begin
        &stop_b
		running!(o[].Session.Arduino,false)
    end

	d = OrderedDict{Any,Any}(
		:Frequencies => f,
		:Session => s,
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
					hbox(:StimulatedVolumes,hskip(1em),:UnstimulatedVolumes),
					vskip(1em),
					hbox(:Collect,hskip(1em),:Start,hskip(1em),:Stop),
					),
					hskip(1em)
					)

end
