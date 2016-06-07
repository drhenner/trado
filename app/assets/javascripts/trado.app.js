trado.app =
{

    jsonErrors: function(xhr, evt, status, form)
    {
        var content, value, _i, _len, _ref, $this;
        $this = form;
        content = $this.children('ul.errors');
        content.find('ul').empty();
        _ref = $.parseJSON(xhr.responseText).errors;
        content.empty();
        // Append errors to list on page
        for (_i = 0, _len = _ref.length; _i < _len; _i++)
        {
            value = _ref[_i];
            content.show().append('<li><i class="icon-cancel-circle"></i>' + value + '</li>');
        }
        // Scroll to error list
        if (!$this.parent().hasClass('modal-content'))
        {
            $('body').scrollTo('.page-header', 800);
        }
    },

    typeahead: function() 
    {
        $("#navSearchInput").typeahead(
        {
            remote: "/search/autocomplete?utf8=✓&query=%QUERY",
            template: " <div class='inner-suggest'> <img src='{{image.file.url}}' height='45' width='45'/> <span> <div>{{value}}</div> <div>{{category_name}}{{}}</div> </span> </div>",
            engine: Hogan,
            limit: 4
        }).on("typeahead:selected", function($e, data) 
        {
            return window.location = "/categories/" + data.category_slug + "/products/" + data.product_slug;
        });
    },
    
    selectDeliveryServicePrice: function() 
    {
        $('body').on('click', '#delivery-services table tbody tr', function()
        {
            $('#delivery-services table tbody tr').removeClass('active');
            $(this).addClass('active');
            $(this).find('td:last-child input').prop("checked", true);

            trado.app.deliveryPriceCheckoutInfo($(this));
        });
    },

    updateDeliveryServicePrice: function()
    {
        $('.update-delivery-service-price').change(function() 
        {
            if (this.value !== "") 
            {
                $.ajax( 
                {
                    url: '/carts/delivery_service_prices',
                    type: 'GET',
                    data: { 'country_id': this.value },
                    dataType: 'json',
                    success: function(data) 
                    {
                        $('#delivery-services').html(data.table);
                        $('#delivery-services input:radio').each(function() 
                        {
                            if ($(this).is(':checked')) 
                            {
                                trado.app.deliveryPriceCheckoutInfo($(this).parent().parent());
                                
                                $(this).parent().addClass('active');
                            }
                        });
                    }
                });
            } 
            else 
            {
                $('#delivery-services').html('<p>Please select a delivery country in order to view a list of available delivery services...</p>');
            }
        });
    },

    updateSelectedSku: function()
    {
        $('.updated-selected-sku').change(function()
        {
            var skuId = $(this).val(),
                productId = $(this).attr('data-product-id'),
                accessoryId = $('.updated-selected-accessory').val();
            $.ajax(
            {
                url: '/products/' + productId + '/skus/' + skuId + '?accessory_id=' + accessoryId,
                type: "GET",
                dataType: "json",
                success: function(data)
                {
                    $('#price').html(data.price);
                    $('#product-actions').html(data.html);
                }
            });
            return false;
        });
    },

    updateSelectedAccessory: function()
    {
        $('.updated-selected-accessory').change(function()
        {
            var accessoryId = $(this).val(),
                productId = $(this).attr('data-product-id'),
                skuId = $('.updated-selected-sku').val();
            $.ajax(
            {
                url: '/products/' + productId + '/accessories?accessory_id=' + accessoryId + '&sku_id=' + skuId,
                type: "GET",
                dataType: "json",
                success: function(data)
                {
                    $('#price').html(data.price);
                }
            });
            return false;
        });
    },

    addToCart: function()
    {
        $('body').on('submit', '#new_cart_item', function ()
        {
            var url = $(this).attr('action')
            $.ajax(
            {
                url: url,
                type: "POST",
                data: $(this).serialize(),
                dataType: "json",
                success: function(data)
                {
                    $('#cart-container').html(data.html);
                    $('#basket-icon span').html(data.cart_quantity);
                },
                error: function(xhr, status, error)
                {
                    $('#validate-cart-item').html(xhr.responseJSON.html);
                    $('#validateCartItemModal').modal('show');
                }
            });
            return false;
        });   
    },

    deleteCartItem: function()
    {
        $('body').on('click', '.delete-cart-item', function ()
        {
            var cartItemId = $(this).attr('data-cart-item-id');
            $.ajax(
            {
                url: '/cart_items/' + cartItemId,
                type: "DELETE",
                dataType: "json",
                success: function(data)
                {
                    $('#cart-container').html(data.popup);
                    $('#cart-wrapper').html(data.cart);
                    $('#basket-icon span').html(data.cart_quantity);
                    $('#net-price').html(data.subtotal);
                    $('#tax-price').html(data.tax);
                    $('#gross-price').html(data.total);
                    if (data.empty_cart)
                    {
                        $('.checkout-button').remove();
                    }
                }
            });
            return false;
        });
    },

    updateCartItem: function()
    {
        $('body').on('click', '.update-cart-item', function ()
        {
            var cartItemId = $(this).attr('data-cart-item-id'),
                platform = $(this).attr('data-platform'),
                quantity = $('.item-quantity-' + cartItemId + '-' + platform).val();


            $.ajax(
            {
                url: '/cart_items/' + cartItemId,
                type: "PATCH",
                data: { cart_item: { quantity: quantity } },
                dataType: "json",
                success: function(data)
                {
                    $('#cart-container').html(data.popup);
                    $('#cart-wrapper').html(data.cart);
                    $('#basket-icon span').html(data.cart_quantity);
                    $('#net-price').html(data.subtotal);
                    $('#tax-price').html(data.tax);
                    $('#gross-price').html(data.total);
                    if (data.empty_cart)
                    {
                        $('.checkout-button').remove();
                    }
                },
                error: function(xhr, status, error)
                {
                    $('#validate-cart-item').html(xhr.responseJSON.html);
                    $('#validateCartItemModal').modal('show');
                }
            });
            return false;
        });
    },

    deliveryPriceCheckoutInfo: function($parentElem)
    {
        var price = $parentElem.attr('data-price'),
            total = $parentElem.attr('data-total'),
            subtotal = $parentElem.attr('data-sub-total'),
            tax = $parentElem.attr('data-tax'),
            $checkoutElem = $('#checkout-breakdown');


        $checkoutElem.find('div:last-child span:first-child').text(price);
        $checkoutElem.find('div:last-child span:nth-child(2)').text(subtotal);
        $checkoutElem.find('div:last-child span:last-child').text(tax);
        $('#checkout-total div:last-child strong').text(total);
    },

    notifyMe: function()
    {
        $('body').on('click', '.notify-me', function()
        {
            var skuId = $('.updated-selected-sku').val();

            $.ajax(
            {
                url: '/skus/' + skuId + '/notify_me/new',
                type: "GET",
                dataType: "json",
                success: function(data)
                {
                    $('#notify-me-form').html(data.modal);
                    $('#notifyMeModal').modal('show');
                }
            });
            return false;
        });
    },

    createNotifyMe: function()
    {
        $('body').on('submit', '#new_notify_me_notification', function ()
        {
            var $this = $(this),
                url = $this.attr('action');
            $.ajax(
            {
                url: url,
                type: "POST",
                data: $this.serialize(),
                dataType: "json",
                success: function(data)
                {
                    $('#notifyMeModal .btn.green').remove();
                    $('#notifyMeModal .modal-body').html('<p>Thank you, we have created a notification request for <b>' + data.notification.email + '</b>.</p>');
                },
                error: function(xhr, evt, status)
                {
                    trado.app.jsonErrors(xhr, evt, status, $this);
                }
            });
            return false;
        });
    }
}