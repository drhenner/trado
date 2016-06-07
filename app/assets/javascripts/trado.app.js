trado.app =
{
    updatePrice: function(url, queryString, elem, elemTwo)
    {
        $(elem).change(function() 
        {
            var id, idTwo;
            id = $(this).val();
            idTwo = $(elemTwo).val();
            return $.get(url.concat(id, queryString, idTwo));
        });
    },

    jsonErrors: function() 
    {
        $(document).on("ajax:error", "form.remote-form", function(evt, xhr, status, error) 
        {

            var errors;
            errors = $.parseJSON(xhr.responseJSON.errors);
            if ($(this).hasClass('loading-form'))
            {
                // grant access to form fields and stop the loading animation
                $(this).css('pointer-events', 'auto');
                $(this).spin(false);
            }
            // removes the old error elements
            $('input').each(function()
            {
                if ($(this).parent().hasClass('field-with-errors'))
                {
                    $(this).unwrap();
                    $(this).next().remove();
                }
            });
            // iterates through the list of errors
            $.each(errors, function(key, value) 
            {
                var $element, $errorTarget;
                // assigns a recognisable key for input element identification
                tempKey = key.split('_');
                key = tempKey[tempKey.length-1] === "id" ? tempKey[0] : key
                // selects the element
                $element = $("input[name*='" + key + "']");
                if ($element.length === 0)
                {
                    $element =  $("select[name*='" + key + "']");
                }
                $errorTarget = '.error-explanation';
                //cleans the value
                key = key.split('_').join(' ');
                // updates the error messages
                if ($element.parent().next().is($errorTarget)) 
                {
                    return $($errorTarget).html('<span>' + key + '</span> ' + value);
                } 
                // adds the error elements, if requried
                else 
                {
                    $element.wrap('<div class="field-with-errors"></div>');
                    return $element.parent().after('<span class="' + $errorTarget.split('.').join('') + '"><span>' + key + '</span> ' + value + '</span>');
                }
            });
        });
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

    duplicateAddress: function() 
    {
        $('#use_billing_address').change(function() 
        {
            if (this.checked) 
            {
                $('.copy-billing').each(function() 
                {
                    fieldValue = $(this).val();
                    fieldAttribute = $(this).attr('data-field-name');
                    $('[data-field-name="delivery-' + fieldAttribute + '"]').val(fieldValue).trigger('change');
                });
            } 
            else 
            {
                return $('[data-field-name*="delivery-"').val('');
            }
        });
    },

    selectDeliveryServicePrice: function() 
    {
        $('body').on('click', '.delivery-service-prices .option', function()
        {   
            var name = $(this).find('h5').text(),
                price = $(this).attr('data-price'),
                tax = $(this).attr('data-tax'),
                total = $(this).attr('data-total');

            $('#delivery-summary').find('td:first-child .normal').text(name);
            $('#delivery-summary').find('td:last-child').text(price);
            $('#tax-summary').find('td:last-child').text(tax);
            $('#total-summary').find('td:last-child').text(total);
            $(this).find('input:radio').prop('checked', true);
            $('.option').removeClass('active');
            return $(this).addClass('active');
        });
    },

    updateDeliveryServicePrice: function()
    {
        $('.delivery-service-prices .option input:radio').each(function() 
        {
            if ($(this).is(':checked')) 
            {
                $(this).parent().addClass('active');
            }
        });
        $('.update-delivery-service-price select').each(function()
        {
            trado.app.updateDeliveryServiceList(this);
        })
        $('.update-delivery-service-price select').change(function() 
        {
            trado.app.updateDeliveryServiceList(this);
        });
    },

    printPage: function()
    {
        $('body').on('click', '.print-page', function()
        {
            window.print();
            return false;
        });
    },

    updateDeliveryServiceList: function(elem)
    {
        if (elem.value !== "") 
        {
            $.ajax('/baskets/delivery_service_prices/update', 
            {
                type: 'GET',
                data: 
                {
                    'country_id': elem.value,
                    'object_type': elem.name.split('[')[0]
                },
                dataType: 'html',
                success: function(data) 
                {
                    $('.delivery-service-prices .control-group .controls').html(data);
                    $('.delivery-service-prices .option input:radio').each(function() 
                    {
                        if ($(this).is(':checked')) 
                        {
                            var name = $(this).parent().find('h5').text(),
                                price = $(this).parent().attr('data-price'),
                                tax = $(this).parent().attr('data-tax'),
                                total = $(this).parent().attr('data-total');

                            $('#delivery-summary').find('td:first-child .normal').text(name);
                            $('#delivery-summary').find('td:last-child').text(price);
                            $('#tax-summary').find('td:last-child').text(tax);
                            $('#total-summary').find('td:last-child').text(total);
                            return $(this).parent().addClass('active');
                        }
                    });
                }
            });
        } 
        else 
        {
            return $('.delivery-service-prices .control-group .controls').html('<p class="delivery_service_prices_notice">Select a delivery country to view the available delivery prices.</p>');
        }
    }
}