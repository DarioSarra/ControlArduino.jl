function Widgets.widget(s::SessionStruct)
	p = button("Prepare Session Info")
    # m = textbox(value = "test") # Subject ID
	m = mytextbox("Subject"; value = "test")
    w = myspinbox("Weight in g";value= 25) #spinbox([1,700]; value = 25) # Weight
    d = mydatepicker("Day", today()) # widget(today()) # Date
	f = textbox(value = default_dir) # Directory
    a = dropdown(get_port_list(); value ="chose a port") # Serial Port address

	res = Observable{String}("Waiting for input")


	output = Observable{SessionStruct}(SessionStruct(missing))
	Interact.@map! output begin
		&p
	    SessionStruct(m[],w[],d[], f[], a[])
	end

	i = Observable{}(textarea(;value = "Waiting for input", rows = 2))
	function update_res(m,w,s)
		textarea(;value = "Subject: "*m*", "*string(w)*
			"g\n"*s.FileName, rows = 2)
	end

	Interact.@map! i update_res(&m,&w,&output)

	wdg = Widget{:Session_attributes}(
            OrderedDict(
                    :MouseID => m,
                    :Weight => w,
                    :Day => d,
                    :Arduino => a,
					:Info => i,
					:Prepare => p),
            output = output)

	@layout! wdg vbox(vskip(1em),
			hbox(
				vbox(
						hbox(:MouseID,hskip(1em), :Weight),
						vskip(1em),
						hbox(:Day,hskip(1em),:Arduino),
					),
				hskip(1em),
				:Info
				),
			:Prepare
		)
end

function mytextbox(label::String; value = "", hint = "insert text")
	mytextbox_d = OrderedDict(:label => label, :w => textbox(hint; value = value))
	mytextbox_output = map(t->t, mytextbox_d[:w])
	w = Interact.Widget{:mytextbox}(mytextbox_d, output = mytextbox_output)
	@layout! w vbox(:label, :w) # observe(_) refers to the output of the widget
	return w
end

function myspinbox(label::String; minmax = nothing, value = nothing)
	if !isnothing(minmax)
		length(minmax) == 2 || error("indicate 2 values for min max")
	end
	d = OrderedDict(:label => label, :w => spinbox(minmax; value = value))
	o = map(t->t, d[:w])
	w = Interact.Widget{:myspinbox}(d, output = o)
	@layout! w vbox(:label, :w) # observe(_) refers to the output of the widget
	return w
end

function mydatepicker(label::String, val)
	d = OrderedDict(:label => label, :w => datepicker(value = val))
	o = map(t->t, d[:w])
	w = Interact.Widget{:mydatepicker}(d, output = o)
	@layout! w vbox(:label, :w)
	return w
end
