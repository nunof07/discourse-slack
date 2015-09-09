export default Ember.View.extend({
	tagName: '',
	isVirtual: true,
	templateName: Em.computed.alias("slack-count")
});
