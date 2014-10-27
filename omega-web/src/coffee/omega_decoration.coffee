orderForType =
  'FixedProfile': -2000
  'PacProfile': -1000
  'VirtualProfile': 1000
  'SwitchProfile': 2000
  'RuleListProfile': 3000

angular.module('omegaDecoration', []).value('profileIcons', {
  'DirectProfile': 'glyphicon-transfer'
  'SystemProfile': 'glyphicon-off'
  'AutoDetectProfile': 'glyphicon-file'
  'FixedProfile': 'glyphicon-globe'
  'PacProfile': 'glyphicon-file'
  'VirtualProfile': 'glyphicon-question-sign'
  'RuleListProfile': 'glyphicon-list'
  'SwitchProfile': 'glyphicon-retweet'
}).constant('profileOrder', (a, b) ->
  diff = (orderForType[a.profileType] | 0) - (orderForType[b.profileType] | 0)
  return diff if diff != 0
  if a.name == b.name
    0
  else if a.name < b.name
    -1
  else
    1
).directive('omegaProfileIcon', (profileIcons) ->
  restrict: 'A'
  template: '''
    <span ng-style="{color: color || profile.color}"
      ng-class="{'virtual-profile-icon': profile.virtualType}"
      class="glyphicon {{getIcon(profile)}}">
    </span>
    '''
  scope:
    'profile': '=?omegaProfileIcon'
    'icon': '=?icon'
    'color': '=?color'
  link: (scope, element, attrs, ngModel) ->
    scope.profileIcons = profileIcons
    scope.getIcon = (profile) ->
      (scope.icon || scope.profileIcons[profile.virtualType] ||
      profileIcons[profile.profileType])
).directive('omegaProfileInline', ->
  restrict: 'A'
  template: '''
    <span omega-profile-icon="profile"></span>
    {{dispName ? dispName(profile) : profile.name}}
    '''
  scope:
    'profile': '=omegaProfileInline'
    'dispName': '=?dispName'
).directive('omegaHtml', ($compile) ->
  restrict: 'A'
  link: (scope, element, attrs, ngModel) ->
    locals =
      $profile: (profile = 'profile', dispName = 'dispNameFilter') ->
        """
        <span class="profile-inline" omega-profile-inline="#{profile}"
          disp-name="#{dispName}"></span>
        """
    getHtml = -> scope.$eval(attrs.omegaHtml, locals)
    scope.$watch getHtml, (html) ->
      element.html(html)
      $compile(element.contents())(scope)
).directive('omegaProfileSelect', ($timeout, profileIcons) ->
  restrict: 'A'
  templateUrl: 'partials/omega_profile_select.html'
  require: '?ngModel'
  scope:
    'profiles': '&omegaProfileSelect'
    'defaultText': '@?defaultText'
    'dispName': '=?dispName'
  link: (scope, element, attrs, ngModel) ->
    scope.profileIcons = profileIcons
    scope.currentProfiles = []
    scope.dispProfiles = undefined
    updateView = ->
      scope.profileIcon = ''
      for profile in scope.currentProfiles
        if profile.name == scope.profileName
          scope.selectedProfile = profile
          scope.profileIcon = profileIcons[profile.profileType]
          break
    scope.$watch(scope.profiles, ((profiles) ->
      scope.currentProfiles = profiles
      if scope.dispProfiles?
        scope.dispProfiles = currentProfiles
      updateView()
    ), true)

    scope.toggled = (open) ->
      if open and not scope.dispProfiles?
        scope.dispProfiles = scope.currentProfiles
        scope.toggled = undefined

    if ngModel
      ngModel.$render = ->
        scope.profileName = ngModel.$viewValue
        updateView()

    scope.setProfileName = (name) ->
      if ngModel
        ngModel.$setViewValue(name)
        ngModel.$render()

    scope.getName = (profile) ->
      if profile
        scope.dispName(profile) || profile.name
)
