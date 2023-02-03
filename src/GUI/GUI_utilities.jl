function labeled_widget(label, or; val = nothing, kwargs...)
	d = OrderedDict(:label => label, :w => or(val; kwargs...))
	o = map(t->t, d[:w])
	w = Interact.Widget{:labeled}(d, output = o)
	@layout! w vbox(:label, :w)
	return w
end