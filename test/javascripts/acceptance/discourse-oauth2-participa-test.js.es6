
// Visit http://localhost:3000/qunit?module=Acceptance%3A%20Discourse%20OAuth2%20Participa
import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse OAuth2 Participa', {
  loggedIn: false,
  settings: { participa_enabled: true }
});

test('Sign up button', () => {
  visit('/');
  andThen(() => {
    ok(!exists('.widget-button.sign-up-button'), 'should not be rendered.');
  });
});
