import computed from 'ember-addons/ember-computed-decorators';
import AppController from 'discourse/controllers/application';

// See:
// - https://meta.discourse.org/t/overwriting-controllers-in-plugin/40675
// - https://guides.emberjs.com/v2.10.0/object-model/reopening-classes-and-instances/
export default {
  name: 'oauth2-application',
  initialize() {

    if (Discourse.SiteSettings.participa_enabled) {
      AppController.reopen({
        @computed()
        canSignUp() {
          return false;
        }
      });
    }
    /*
    AppController.reopen({
      @computed()
      canSignUp() {
        return !Discourse.SiteSettings.participa_enabled && this._super();
      }
    });
    */

  }
}
