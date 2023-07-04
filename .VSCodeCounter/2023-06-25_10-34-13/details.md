# Details

Date : 2023-06-25 10:34:13

Directory /Users/soknathmil/Documents/test-apps/oss_app/lib

Total : 76 files,  13486 codes, 481 comments, 820 blanks, all 14787 lines

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/constants/constants.dart](/lib/constants/constants.dart) | Dart | 142 | 0 | 5 | 147 |
| [lib/data/models/message.dart](/lib/data/models/message.dart) | Dart | 14 | 0 | 3 | 17 |
| [lib/data/services/appwrite_service.dart](/lib/data/services/appwrite_service.dart) | Dart | 556 | 40 | 55 | 651 |
| [lib/data/services/firebase_service.dart](/lib/data/services/firebase_service.dart) | Dart | 77 | 2 | 7 | 86 |
| [lib/firebase_options.dart](/lib/firebase_options.dart) | Dart | 72 | 12 | 6 | 90 |
| [lib/main.dart](/lib/main.dart) | Dart | 41 | 1 | 5 | 47 |
| [lib/presentation/controllers/appeal_list_controller.dart](/lib/presentation/controllers/appeal_list_controller.dart) | Dart | 34 | 3 | 6 | 43 |
| [lib/presentation/controllers/config_controller.dart](/lib/presentation/controllers/config_controller.dart) | Dart | 29 | 3 | 7 | 39 |
| [lib/presentation/controllers/contact_us_controller.dart](/lib/presentation/controllers/contact_us_controller.dart) | Dart | 29 | 2 | 7 | 38 |
| [lib/presentation/controllers/doc_type_controller.dart](/lib/presentation/controllers/doc_type_controller.dart) | Dart | 39 | 3 | 9 | 51 |
| [lib/presentation/controllers/emergency_controller.dart](/lib/presentation/controllers/emergency_controller.dart) | Dart | 28 | 1 | 5 | 34 |
| [lib/presentation/controllers/journal_controller.dart](/lib/presentation/controllers/journal_controller.dart) | Dart | 27 | 2 | 5 | 34 |
| [lib/presentation/controllers/login_controller.dart](/lib/presentation/controllers/login_controller.dart) | Dart | 51 | 2 | 7 | 60 |
| [lib/presentation/controllers/message_controller.dart](/lib/presentation/controllers/message_controller.dart) | Dart | 41 | 1 | 8 | 50 |
| [lib/presentation/controllers/mngt_controller.dart](/lib/presentation/controllers/mngt_controller.dart) | Dart | 28 | 1 | 5 | 34 |
| [lib/presentation/controllers/news_controller.dart](/lib/presentation/controllers/news_controller.dart) | Dart | 27 | 2 | 5 | 34 |
| [lib/presentation/controllers/notification_controller.dart](/lib/presentation/controllers/notification_controller.dart) | Dart | 67 | 4 | 7 | 78 |
| [lib/presentation/controllers/open_access_controller.dart](/lib/presentation/controllers/open_access_controller.dart) | Dart | 27 | 2 | 5 | 34 |
| [lib/presentation/controllers/pois_controller.dart](/lib/presentation/controllers/pois_controller.dart) | Dart | 59 | 3 | 7 | 69 |
| [lib/presentation/controllers/request_controller.dart](/lib/presentation/controllers/request_controller.dart) | Dart | 32 | 2 | 6 | 40 |
| [lib/presentation/controllers/unit_controller.dart](/lib/presentation/controllers/unit_controller.dart) | Dart | 33 | 2 | 7 | 42 |
| [lib/presentation/controllers/vision_controller.dart](/lib/presentation/controllers/vision_controller.dart) | Dart | 29 | 3 | 7 | 39 |
| [lib/presentation/models/map_marker_model.dart](/lib/presentation/models/map_marker_model.dart) | Dart | 48 | 0 | 4 | 52 |
| [lib/presentation/models/push_notification.dart](/lib/presentation/models/push_notification.dart) | Dart | 12 | 0 | 2 | 14 |
| [lib/presentation/pages/appeal_list_page.dart](/lib/presentation/pages/appeal_list_page.dart) | Dart | 16 | 0 | 4 | 20 |
| [lib/presentation/pages/appeal_page.dart](/lib/presentation/pages/appeal_page.dart) | Dart | 316 | 29 | 18 | 363 |
| [lib/presentation/pages/complete_form_page.dart](/lib/presentation/pages/complete_form_page.dart) | Dart | 342 | 14 | 7 | 363 |
| [lib/presentation/pages/contact_us_page.dart](/lib/presentation/pages/contact_us_page.dart) | Dart | 121 | 1 | 6 | 128 |
| [lib/presentation/pages/edit_profile_page.dart](/lib/presentation/pages/edit_profile_page.dart) | Dart | 165 | 59 | 9 | 233 |
| [lib/presentation/pages/emergency_page.dart](/lib/presentation/pages/emergency_page.dart) | Dart | 101 | 0 | 12 | 113 |
| [lib/presentation/pages/ems_request_page.dart](/lib/presentation/pages/ems_request_page.dart) | Dart | 666 | 9 | 21 | 696 |
| [lib/presentation/pages/general_request_form.dart](/lib/presentation/pages/general_request_form.dart) | Dart | 633 | 6 | 21 | 660 |
| [lib/presentation/pages/home_page.dart](/lib/presentation/pages/home_page.dart) | Dart | 851 | 12 | 31 | 894 |
| [lib/presentation/pages/journal_page.dart](/lib/presentation/pages/journal_page.dart) | Dart | 172 | 4 | 15 | 191 |
| [lib/presentation/pages/login_page.dart](/lib/presentation/pages/login_page.dart) | Dart | 52 | 0 | 4 | 56 |
| [lib/presentation/pages/main_page.dart](/lib/presentation/pages/main_page.dart) | Dart | 256 | 15 | 37 | 308 |
| [lib/presentation/pages/map_view_page.dart](/lib/presentation/pages/map_view_page.dart) | Dart | 300 | 2 | 15 | 317 |
| [lib/presentation/pages/message_page.dart](/lib/presentation/pages/message_page.dart) | Dart | 135 | 9 | 17 | 161 |
| [lib/presentation/pages/news_detail_page.dart](/lib/presentation/pages/news_detail_page.dart) | Dart | 68 | 0 | 5 | 73 |
| [lib/presentation/pages/news_page.dart](/lib/presentation/pages/news_page.dart) | Dart | 139 | 2 | 11 | 152 |
| [lib/presentation/pages/notification_detail_page.dart](/lib/presentation/pages/notification_detail_page.dart) | Dart | 70 | 4 | 5 | 79 |
| [lib/presentation/pages/notification_page.dart](/lib/presentation/pages/notification_page.dart) | Dart | 190 | 8 | 12 | 210 |
| [lib/presentation/pages/open_access_page.dart](/lib/presentation/pages/open_access_page.dart) | Dart | 170 | 4 | 15 | 189 |
| [lib/presentation/pages/open_business_request_form.dart](/lib/presentation/pages/open_business_request_form.dart) | Dart | 1,145 | 27 | 26 | 1,198 |
| [lib/presentation/pages/payment_detail_page.dart](/lib/presentation/pages/payment_detail_page.dart) | Dart | 348 | 11 | 14 | 373 |
| [lib/presentation/pages/pdf_viewer_page.dart](/lib/presentation/pages/pdf_viewer_page.dart) | Dart | 103 | 1 | 9 | 113 |
| [lib/presentation/pages/pois_page.dart](/lib/presentation/pages/pois_page.dart) | Dart | 24 | 0 | 4 | 28 |
| [lib/presentation/pages/profile_page.dart](/lib/presentation/pages/profile_page.dart) | Dart | 504 | 27 | 16 | 547 |
| [lib/presentation/pages/qr_scanner_page.dart](/lib/presentation/pages/qr_scanner_page.dart) | Dart | 120 | 7 | 12 | 139 |
| [lib/presentation/pages/request_detail_page.dart](/lib/presentation/pages/request_detail_page.dart) | Dart | 600 | 0 | 13 | 613 |
| [lib/presentation/pages/request_page.dart](/lib/presentation/pages/request_page.dart) | Dart | 140 | 2 | 11 | 153 |
| [lib/presentation/pages/splash_screen.dart](/lib/presentation/pages/splash_screen.dart) | Dart | 38 | 0 | 6 | 44 |
| [lib/presentation/pages/staff_list_page.dart](/lib/presentation/pages/staff_list_page.dart) | Dart | 57 | 1 | 10 | 68 |
| [lib/presentation/pages/tax_payment_page.dart](/lib/presentation/pages/tax_payment_page.dart) | Dart | 462 | 9 | 9 | 480 |
| [lib/presentation/pages/trash_request_form.dart](/lib/presentation/pages/trash_request_form.dart) | Dart | 1,085 | 82 | 25 | 1,192 |
| [lib/presentation/pages/unit_chat_page.dart](/lib/presentation/pages/unit_chat_page.dart) | Dart | 144 | 2 | 13 | 159 |
| [lib/presentation/pages/validate_account.dart](/lib/presentation/pages/validate_account.dart) | Dart | 89 | 3 | 7 | 99 |
| [lib/presentation/pages/verify_otp_page.dart](/lib/presentation/pages/verify_otp_page.dart) | Dart | 280 | 11 | 14 | 305 |
| [lib/presentation/pages/vision_detail_page.dart](/lib/presentation/pages/vision_detail_page.dart) | Dart | 72 | 0 | 5 | 77 |
| [lib/presentation/pages/vision_page.dart](/lib/presentation/pages/vision_page.dart) | Dart | 111 | 0 | 8 | 119 |
| [lib/presentation/widgets/appeal_list.dart](/lib/presentation/widgets/appeal_list.dart) | Dart | 125 | 2 | 12 | 139 |
| [lib/presentation/widgets/bottom_pin.dart](/lib/presentation/widgets/bottom_pin.dart) | Dart | 144 | 8 | 12 | 164 |
| [lib/presentation/widgets/form_process.dart](/lib/presentation/widgets/form_process.dart) | Dart | 212 | 3 | 23 | 238 |
| [lib/presentation/widgets/full_map.dart](/lib/presentation/widgets/full_map.dart) | Dart | 127 | 0 | 22 | 149 |
| [lib/presentation/widgets/horizonMenu.dart](/lib/presentation/widgets/horizonMenu.dart) | Dart | 59 | 1 | 6 | 66 |
| [lib/presentation/widgets/material_design_indicator.dart](/lib/presentation/widgets/material_design_indicator.dart) | Dart | 38 | 1 | 10 | 49 |
| [lib/presentation/widgets/notification_badge.dart](/lib/presentation/widgets/notification_badge.dart) | Dart | 25 | 0 | 4 | 29 |
| [lib/presentation/widgets/poi_destination.dart](/lib/presentation/widgets/poi_destination.dart) | Dart | 140 | 2 | 8 | 150 |
| [lib/presentation/widgets/process_timeline.dart](/lib/presentation/widgets/process_timeline.dart) | Dart | 224 | 3 | 23 | 250 |
| [lib/presentation/widgets/profile_card.dart](/lib/presentation/widgets/profile_card.dart) | Dart | 77 | 1 | 6 | 84 |
| [lib/presentation/widgets/request_list.dart](/lib/presentation/widgets/request_list.dart) | Dart | 121 | 4 | 12 | 137 |
| [lib/presentation/widgets/tab_view.dart](/lib/presentation/widgets/tab_view.dart) | Dart | 121 | 1 | 7 | 129 |
| [lib/presentation/widgets/vetical_tab_view.dart](/lib/presentation/widgets/vetical_tab_view.dart) | Dart | 120 | 3 | 7 | 130 |
| [lib/routes/routes.dart](/lib/routes/routes.dart) | Dart | 273 | 0 | 4 | 277 |
| [lib/utils/general_utils.dart](/lib/utils/general_utils.dart) | Dart | 30 | 0 | 4 | 34 |
| [lib/utils/map_utils.dart](/lib/utils/map_utils.dart) | Dart | 23 | 0 | 3 | 26 |

[Summary](results.md) / Details / [Diff Summary](diff.md) / [Diff Details](diff-details.md)