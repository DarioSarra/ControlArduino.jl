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