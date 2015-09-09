export default Ember.Component.extend({
	tagName: '',
	dropdownVisible: false,
	
	memberCount: function() {
		var members = this.get('members');
		
		if (Ember.isArray(members)) {
			return members.length;
		}
		
		return 0;
	}.property('members'),
	
	showCount: function () {
		return (this.get('memberCount') > 0);
	}.property('memberCount'),
	
	_refreshService: function () {
		var _this = this,
			interval = Discourse.SiteSettings.slack_interval > 0 ? Discourse.SiteSettings.slack_interval : 60000;
		
		Discourse.ajax('/slack/team.json')
				 .then(function (data) {
					 _this.set('team', data);
				 });
		
		Discourse.ajax('/slack/list.json')
				 .then(function (data) {
					 if (data) {
					 	_this.set('members', data.members);
					 }
				 });
		
		Ember.run.later(this, function() {
			_this._refreshService();
		}, interval);
	},
	
	_init: function() {
		this._refreshService();
	}.on('init')
});
