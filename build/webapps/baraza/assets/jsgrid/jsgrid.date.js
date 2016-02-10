/*
 * jsGrid v1.4.0 (http://js-grid.com)
 * (c) 2016 Artem Tabalin
 * Licensed under MIT (https://github.com/tabalinas/jsgrid/blob/master/LICENSE)
 * Additions development by Dennis Gichangi
 */

(function(window, $, undefined) {

	var MyDateField = function(config) {
		jsGrid.Field.call(this, config);
	};
	 
	MyDateField.prototype = new jsGrid.Field({
	 
		css: "date-field",            // redefine general property 'css'
		align: "center",              // redefine general property 'align'
	 
		myCustomProperty: "foo",      // custom property
	 
		sorter: function(date1, date2) {
		    return new Date(date1) - new Date(date2);
		},
	 
		itemTemplate: function(value) {
		    return new Date(value).toDateString();
		},
	 
		insertTemplate: function(value) {
		    return this._insertPicker = $("<input>").datepicker({ defaultDate: new Date() });
		},
	 
		editTemplate: function(value) {
		    return this._editPicker = $("<input>").datepicker().datepicker("setDate", new Date(value));
		},
	 
		insertValue: function() {
		    return this._insertPicker.datepicker("getDate").toISOString();
		},
	 
		editValue: function() {
		    return this._editPicker.datepicker("getDate").toISOString();
		}
	});
	 
	jsGrid.fields.date = MyDateField;

}(jsGrid, jQuery));

