module EViewTest__Generic

  class App < E
    class Sandbox
      attr_reader :params

      def initialize params = {}
        @params = params
      end
    end

    map '/'
    engine :ERB
    layout :layout

    setup /custom_context/ do
      layout :layout__custom_context
    end

    setup /custom_locals/ do
      layout :layout__custom_locals
    end

    setup :custom___ext do
      engine_ext :xhtml
    end

    def index
      @greeting = 'World'
      render
    end

    def get_partial
      render_partial
    end

    def render_given action
      render action.to_sym
    end

    def render_given_partial action
      render_partial action.to_sym
    end

    def some___action
      'some string'
    end

    def templateless_action

    end

    def custom_context
      render Sandbox.new(params[:sandbox_params])
    end

    def custom_context_action action
      render action.to_sym, Sandbox.new(params[:sandbox_params])
    end

    def custom_locals
      render params
    end

    def custom_locals_action action
      render_partial action.to_sym, params
    end

    def inline
      render { render_partial { 'World' } }
    end

    def inline_partial
      render_partial { 'World' }
    end

    def custom___ext
      render_partial
    end

  end

  Spec.new App do

    Should 'render current action with layout' do
      r = get
      is?(r.body) == 'Hello World!'
    end
    Should 'render current action without layout' do
      r = get :partial
      is?(r.body) == 'get_partial'
    end

    Should 'correctly resolve path by given action' do
      And 'render with layout' do
        r = get :render_given, :some___action
        is?(r.body) == 'Hello render_given!'
      end
      And 'render without layout' do
        r = get :render_given_partial, :some___action
        is?(r.body) == 'render_given_partial'
      end
    end

    Should 'correctly resolve path by given template' do
      And 'render with layout of :render_given action, as the `render` method is executed inside :render_given action' do
        r = get :render_given, :actionless_template
        is?(r.body) == 'Hello render_given!'
      end
      And 'render without layout' do
        r = get :render_given_partial, :actionless_template
        is?(r.body) == 'render_given_partial'
      end
    end

    Testing 'inline rendering' do
      Should 'render with layout' do
        expect(get(:inline).body) == 'Hello World!'
      end
      And 'without layout' do
        expect(get(:inline_partial).body) == 'World'
      end
    end

    Testing 'extension' do
      expect(get('custom-ext').body) == '.xhtml'
    end

    Should 'raise error' do
      When 'non-existing action/template given' do
        expect { get :render_given, :blah! }.to_raise_error
      end
      When 'given action has no template' do
        expect { get :render_given, :templateless_action }.to_raise_error
      end
    end

    Should 'render current action within custom context' do
      r = get :custom_context, :sandbox_params => {'foo' => 'bar'}, :sensitive_data => 'blah!'
      expect(r.body) == 'layout-foo=bar;layout-sensitive_data=;foo=bar;sensitive_data='
    end
    Should 'render given action within custom context' do
      r = get :custom_context_action, :custom_context, :sandbox_params => {'foo' => 'bar'}, :sensitive_data => 'blah!'
      expect(r.body) == 'layout-foo=bar;layout-sensitive_data=;foo=bar;sensitive_data='
    end

    Should 'render current action with custom locals' do
      r = get :custom_locals, 'foo' => 'bar'
      expect(r.body) == 'layout-foo=bar;foo=bar'
    end
    Should 'render given action with custom locals' do
      r = get :custom_locals_action, :custom_locals, 'foo' => 'bar'
      expect(r.body) == 'foo=bar'
    end

  end
end
