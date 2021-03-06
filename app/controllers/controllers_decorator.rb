SpreeMultiTenant.tenanted_controllers.each do |controller|
  controller.class_eval do

    prepend_around_filter :tenant_scope

    def current_tenant
      Multitenant.current_tenant
    end

    private
      
      def tenant_scope
        tenant = Spree::Tenant.find_by_domain(request.host)
        # tenant = Spree::Tenant.find_by_domain(request.env['SERVER_NAME'])
        raise 'DomainUnknown' unless tenant

        # Add tenant views path
        path = "app/tenants/#{tenant.code}/views"
        prepend_view_path(path)

        # Execute ActiveRecord queries within the scope of the tenant
        Multitenant.with_tenant tenant do
          yield
        end
      end

  end
end
