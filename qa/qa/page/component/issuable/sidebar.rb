# frozen_string_literal: true

module QA
  module Page
    module Component
      module Issuable
        module Sidebar
          extend QA::Page::PageConcern

          def self.included(base)
            super

            base.view 'app/assets/javascripts/sidebar/components/assignees/assignee_avatar.vue' do
              element :avatar_image
            end

            base.view 'app/assets/javascripts/sidebar/components/assignees/uncollapsed_assignee_list.vue' do
              element :more_assignees_link
            end

            base.view 'app/assets/javascripts/sidebar/components/labels/sidebar_labels.vue' do
              element :labels_block
            end

            base.view 'app/assets/javascripts/vue_shared/components/sidebar/labels_select_vue/dropdown_value.vue' do
              element :selected_label_content
            end

            base.view 'app/assets/javascripts/vue_shared/components/sidebar/labels_select_vue/dropdown_contents.vue' do
              element :labels_dropdown_content
            end

            base.view 'app/assets/javascripts/vue_shared/components/sidebar/labels_select/dropdown_title.vue' do
              element :labels_edit_button
            end

            base.view 'app/assets/javascripts/vue_shared/components/sidebar/labels_select_vue/dropdown_contents_labels_view.vue' do
              element :dropdown_input_field
            end

            base.view 'app/views/shared/issuable/_sidebar.html.haml' do
              element :assignee_block
              element :edit_milestone_link
              element :milestone_block
              element :milestone_link
            end
          end

          def assign_milestone(milestone)
            click_element(:edit_milestone_link)
            within_element(:milestone_block) do
              click_link("#{milestone.title}")
            end

            wait_until(reload: false) do
              has_element?(:milestone_block, text: milestone.title, wait: 0)
            end

            refresh
          end

          def click_milestone_link
            click_element(:milestone_link)
          end

          def has_assignee?(username)
            within_element(:assignee_block) do
              wait_until(reload: false) do
                has_text?(username)
              end
            end
          end

          def has_no_assignee_named?(username)
            within_element(:assignee_block) do
              has_no_text?(username, wait: QA::Support::Repeater::DEFAULT_MAX_WAIT_TIME)
            end
          end

          def has_avatar_image_count?(count)
            wait_assignees_block_finish_loading do
              all_elements(:avatar_image, count: count)
            end
          end

          def has_label?(label)
            within_element(:labels_block) do
              !!has_element?(:selected_label_content, label_name: label)
            end
          end

          def has_milestone?(milestone_title)
            wait_milestone_block_finish_loading do
              has_element?(:milestone_link, title: milestone_title)
            end
          end

          def more_assignees_link
            find_element(:more_assignees_link)
          end

          def select_labels_and_refresh(labels)
            Support::Retrier.retry_until do
              click_element(:labels_edit_button)
              has_element?(:labels_dropdown_content, text: labels.first)
            end

            labels.each do |label|
              within_element(:labels_dropdown_content) do
                send_keys_to_element(:dropdown_input_field, [label, :enter])
              end
            end

            click_element(:labels_edit_button)

            labels.each do |label|
              has_element?(:labels_block, text: label, wait: 0)
            end

            refresh

            wait_for_requests
          end

          def toggle_more_assignees_link
            click_element(:more_assignees_link)
          end

          private

          def wait_assignees_block_finish_loading
            within_element(:assignee_block) do
              wait_until(reload: false, max_duration: 10, sleep_interval: 1) do
                finished_loading_block?
                yield
              end
            end
          end

          def wait_milestone_block_finish_loading
            within_element(:milestone_block) do
              wait_until(reload: false, max_duration: 10, sleep_interval: 1) do
                finished_loading_block?
                yield
              end
            end
          end
        end
      end
    end
  end
end
