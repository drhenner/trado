require 'rails_helper'

feature 'Page management' do

    store_setting
    feature_login_admin
    given(:single_page) { create(:standard_page) }

    scenario 'should display an index of pages' do
        single_page

        visit admin_root_path
        find('a[data-original-title="Pages"]').click
        expect(current_path).to eq admin_pages_path
        within 'h2' do
            expect(page).to have_content 'Pages'
        end
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'Pages'
        end
        within 'thead tr th:first-child' do
            expect(page).to have_content 'Title'
        end
        within 'tbody tr td:first-child' do
            expect(page).to have_content single_page.title
        end
    end

    scenario 'should edit a page' do
        single_page

        visit admin_pages_path
        within 'tbody' do
            first('tr').find('td:last-child').first(:link).click
        end
        expect(current_path).to eq edit_admin_page_path(single_page)
        within '#breadcrumbs li.current' do
            expect(page).to have_content 'Edit'
        end
        fill_in('page_title', with: 'page #2')
        fill_in('page_page_title', with: 'page title ting')
        click_button 'Submit'
        expect(current_path).to eq admin_pages_path
        within '.alert.alert-success' do
            expect(page).to have_content 'Page was successfully updated.'
        end
        within 'h2' do
            expect(page).to have_content 'Pages'
        end 
        single_page.reload
        expect(single_page.title).to eq 'page #2'
        expect(single_page.page_title).to eq 'page title ting'
    end
end