function Widgets.widget(s::SessionStruct)
	p = button("Prepare Session Info")
	m = labeled_widget("Subject", textbox; value = "test")
	w = labeled_widget("Weight in g", spinbox; value = 25)
	d = labeled_widget("Day", datepicker; value = today())
	f = labeled_widget("Directory", textbox;value = isdir(default_dir) ? defaultdir : @__DIR__)
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

function stim_wid()
	o = Observable{NTuple}((0,0,0,0)) #2 paranthesis to indicate the argument is a Tuple
	d = OrderedDict(:f1 => spinbox(value = 0), :v1 => spinbox(value = 0),
		:f2 => spinbox(value = 0), :v2 => spinbox(value = 0))
	Interact.@map! o (&d[:f1], &d[:v1], &d[:f2], &d[:v2])
	w = Interact.Widget{:Stim}(d, output = o)
	@layout! w vbox(:f1,:v1,:f2,:v2)
	return w
end

function stim_wid(n::Int64)
	n > 0 || error("Not possible to have less than 1 stimulation type")
	stim_spins = Observable{Any}(dom"div"())
	spins = [stim_wid() for _ in 1:n]
	d = OrderedDict(k=>v for (k,v) in zip(1:n,spins))
	o = Observable{Array{Tuple}}([(0,0,0,0)])
	coll = button("Collect stim frequencies")
	Interact.@map! o begin
		&coll
		[(x[:f1][], x[:v1][],x[:f2][],x[:v2][]) for x in spins]
	end
	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w vbox(coll,hbox(spins...))
end


function stim_wid2(n::Int64)
	n > 0 || error("Not possible to have less than 1 stimulation type")
	spins = [stim_wid() for _ in 1:n]
	d = OrderedDict{Any,Any}(k=>v for (k,v) in zip(1:n,spins))
	o = Observable{FreqStruct}(FreqStruct())
	coll = button("Collect stim frequencies")
	d[:Coll] = coll
	map!(t -> FreqStruct([(x[:f1][], x[:v1][],x[:f2][],x[:v2][]) for x in spins]),o,coll)
	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w vbox(coll,hbox(spins...))
end


function stim_wid3()
	stim_n = labeled_widget("Select # of stim protocols between 1 and 10",spinbox;val = (1:10), value = 1)
	coll = button("Collect stim frequencies")

	stims_layout = Observable{Any}(dom"div"())
	spins = Observable{Any}()
	o = Observable{FreqStruct}(FreqStruct())

	Interact.@map! spins  [stim_wid() for _ in 1:&stim_n]
	Interact.@map! stims_layout begin
		&stim_n
		hbox(spins[]...)
	end

	Interact.@map! o  begin
		&coll
		FreqStruct([(x[:f1][], x[:v1][],x[:f2][],x[:v2][]) for x in spins[]])
	end

	d = OrderedDict{Any,Any}(
		:Stims => stim_n,
		:Coll => coll,
		:Freq => stims_layout
	)
	w = Interact.Widget{:Stims}(d, output = o)
	@layout! w vbox(hbox(coll,stim_n),stims_layout)
end
