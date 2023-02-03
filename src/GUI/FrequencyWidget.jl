#= First we defined a widget look with 5 integer. Later this will be given by the frequency structure.
The 5 integer correspond to 
1st stimunaltion frequency and duration
2nd stimulation frequency and duration
masking light frequency=#
function single_stim_widget(;freq = (0,0,0,0,0))
	o = Observable{NTuple}((freq)) #2 paranthesis to indicate the argument is a Tuple
	d = OrderedDict(:f1 => spinbox(value = freq[1]), :v1 => spinbox(value = freq[2]),
		:f2 => spinbox(value = freq[3]), :v2 => spinbox(value = freq[4]),
		:ml => spinbox(value = freq[5]))
	Interact.@map! o (&d[:f1], &d[:v1], &d[:f2], &d[:v2])
	w = Interact.Widget{:Stim}(d, output = o)
	@layout! w vbox(
		hbox(hskip(0.5em),"HZ_1",:f1),
		hbox(hskip(0.5em),"Vol_1",:v1),
		hbox(hskip(0.5em),"HZ_2",:f2),
		hbox(hskip(0.5em),"Vol_2",:v2),
		hbox(hskip(0.5em),"HZ_LED",:ml)
		)
	return w
end

function stim_widget(stims::Vector{NTuple{5,Int64}})
	[single_stim_widget(freq = x) for x in stims]
end


function tuple_frequencies(f1::T,v1::T,f2::T,v2::T,l::T) where {T <:Vector{Any}}
    all(length(x)== length(f1) for x in [v1,f2,v2,l]) || error("feeded unequal length arrays")
    res = NTuple[]
    for i in 1:length(f1)
        push!(res,(f1[i],v1[i],f2[i],v2[i],l))
    end
    res
end

function tuple_frequencies(f1::T,v1::T,f2::T,v2::T,l::T) where {T <:Vector{Union{Missing,Int64}}}
    all(length(x)== length(f1) for x in [v1,f2,v2,l]) || error("feeded unequal length arrays")
    res = NTuple{5,Int64}[]
    convert_miss(x) = ismissing(x) ? 0 : x
    for i in 1:length(f1)
        push!(res,(convert_miss(f1[i]),convert_miss(v1[i]),
            convert_miss(f2[i]),convert_miss(v2[i]),
			convert_miss(l[i])))
    end
    res
end

function Interact.widget(f::FreqStruct)
	stim_n = labeled_widget("Select # of stim protocols between 1 and 10",spinbox;val = 1:10,
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
	spins = Observable{Any}(stim_widget(tuple_frequencies(f.Frequency1,f.Volumes1,f.Frequency2,f.Volumes2,f.MaskLed)))
	o = Observable{FreqStruct}(f)

	Interact.@map! spins begin
		&stim_n
		if stim_n[] <= f.Stimulations
			[single_stim_widget(;freq = (f.Frequency1[i],f.Volumes1[i],f.Frequency2[i],f.Volumes2[i],f.MaskLed[i])) for i in 1:stim_n[]]
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
		FreqStruct([(x[:f1][], x[:v1][],x[:f2][],x[:v2][],x[:ml][]) for x in spins[]])
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

