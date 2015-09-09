export default Ember.Component.extend({
	tagName: 'li',
	classNames: ['slack-member'],
	classNameBindings: ['isAway:slack-member-away'],
	expanded: false,
	
	isAway: function() {
		return (this.get('presence') === "away");
	}.property('presence'),
	
	caretClass: function () {
		return this.get('expanded')
			? "fa fa-caret-down"
			: "fa fa-caret-right";
	}.property('expanded'),
	
	actions: {
		expand: function () {
			this.toggleProperty('expanded');
		}
	}
});
