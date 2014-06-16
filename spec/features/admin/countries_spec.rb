require 'spec_helper'

feature 'Country management' do

    store_setting
    feature_login_admin

    scenario 'should display an index of countries' do
        country = create(:country)

        visit admin_root_path
        find('a[data-original-title="Countries"]').click
        expect(current_path).to eq admin_countries_path
        within 'h2' do
            expect(page).to have_content 'Countries'
        end
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'Countries'
        end
        within 'thead tr th:first-child' do
            expect(page).to have_content 'Name'
        end
        within 'tbody tr td:first-child' do
            expect(page).to have_content country.name
        end
    end

    scenario 'should add a new country' do

        visit admin_countries_path
        find('.page-header a:first-child').click
        expect(current_path).to eq new_admin_country_path
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'New'
        end
        expect{
            fill_in('country_name', with: 'United Kingdom')
            fill_in('country_language', with: 'English')
            fill_in('country_iso', with: 'EN')
            click_button 'Submit'
        }.to change(Country, :count).by(1)
        expect(current_path).to eq admin_countries_path
        within '.alert' do
            expect(page).to have_content 'Country was successfully created.'
        end
        within 'h2' do
            expect(page).to have_content 'Countries'
        end
    end

    scenario 'should edit a country' do
        country = create(:country, language: 'English')

        visit admin_countries_path
        within 'tbody' do
            first('tr').find('td:last-child').first(:link).click
        end
        expect(current_path).to eq edit_admin_country_path(country)
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'Edit'
        end
        fill_in('country_name', with: 'Canada')
        fill_in('country_iso', with: 'CA')
        click_button 'Submit'
        expect(current_path).to eq admin_countries_path
        within '.alert' do
            expect(page).to have_content 'Country was successfully updated.'
        end
        within 'h2' do
            expect(page).to have_content 'Countries'
        end 
        country.reload
        expect(country.name).to eq 'Canada'
        expect(country.language).to eq 'English'
        expect(country.iso).to eq 'CA'
    end

    scenario 'should display an index of zones' do
        zone = create(:zone)

        visit admin_countries_path
        within '.page-header' do
            find(:xpath, "//a[@title='Zones']").click
        end
        expect(current_path).to eq admin_countries_zones_path
        within 'h2' do
            expect(page).to have_content 'Zones'
        end
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'Zones'
        end
        within 'thead tr th:first-child' do
            expect(page).to have_content 'Name'
        end
        within 'tbody tr td:first-child' do
            expect(page).to have_content zone.name
        end
    end

    scenario "should delete a country", js: true do
        country = create(:country)

        visit admin_countries_path
        expect{
            within 'tbody' do
                first('tr').find('td:last-child a:last-child').click
            end
        }.to change(Country, :count).by(-1)
        within '.alert' do
            expect(page).to have_content('Country was successfully deleted.')
        end
        within 'h2' do
            expect(page).to have_content 'Countries'
        end
    end
end
