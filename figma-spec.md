# Figma mẫu cho ChatApp (bám sát UI hiện tại, tối ưu thêm)

File này mô tả cấu trúc frame, component, token, và animation để bạn dựng nhanh trên Figma. Mỗi section ghi rõ: kích thước, layout, màu, font, icon, variant, prototype action.

## 1) Tokens & Styles
- Font: Inter (hoặc Roboto nếu thiếu). Text styles:
  - H1 24/Bold, H2 20/Semi, Body 16/Reg, Caption 12/Reg.
- Màu:
  - Primary #1B5CCB (AppBar/Bottom Nav gốc), Secondary #0F54CB, Accent #FF4D67 (like), Surface #FFFFFF, Surface Alt #F4F7FB, Border #E4E8EE, Text #111827, Subtext #6B7280, Success #22C55E, Error #EF4444.
- Radius: 20 (card lớn), 12 (ô nhập), 8 (chip/badge).
- Shadow: card 0 8 24 0 rgba(0,0,0,0.08).
- Icon set: Material Symbols Rounded.

## 2) Components (biến thể/variants)
- Button: Primary/Secondary/Ghost + states (default, pressed, disabled, loading). Loading: text fade-out, spinner fade-in.
- TextField: default/focus/error/disabled; prefix icon; eye toggle variant cho mật khẩu.
- Nav Item: inactive/active/badge; icon outline/filled; label.
- Badge: dot / count.
- List Tile: avatar + title + subtitle + trailing; variant unread (tint + badge).
- Bubble: mine/theirs + withStatus + withAttachment; radius không đối xứng (mine: 18/18/6/18, theirs: 18/18/18/6).
- Card Feed: header (avatar+name+time), content, media (1 ảnh), actions (like/comment).
- Bottom Sheet Handle: pill 40x4, radius 2.

## 3) Frames chính (Mobile 390x844)
### Login
- Nền gradient nhẹ từ #A9D3FF → #1B5CCB (opacity 0.85) với overlay blur 8%.
- Card form (Surface, radius 20, shadow). Logo trên, H1 “Welcome Back”, Body “Login to your account”.
- Hai TextField (username, password). Password có eye toggle.
- Nút “Login” full width (Primary). Link “Quên mật khẩu?”, link “Signup”.
- Prototype:
  - On Focus TextField: change to focus variant.
  - On Error: lắc ngang 6px (Smart Animate).
  - On Login: Button → loading variant 220ms; sau đó Navigate → Hub (slide-right 250ms).

### Signup
- Giữ nền/form tương tự. 5 trường: Display Name, Email, Phone, Username, Password.
- Button “Submit” + link “Login”.
- Prototype: form error shake; success → snack (overlay) rồi back Login.

### Hub (Navigation)
- AppBar màu Primary; title đổi theo tab. Actions: search, bell có badge.
- Body: `NavigationBar` M3 (4 tabs: Messages, Friends, Profile, News Feed).
- Prototype:
  - Tab change: icon morph outline→filled, scale 0.9→1 (160ms), indicator pill slide.
  - Title crossfade 120ms.

### Messages (MessList)
- Background Surface Alt (#F4F7FB). List Tile: Avatar (Circle), Title bold, Subtitle ellipsis, trailing time nhỏ, badge unread.
- Empty state: illustration nhỏ + text “Chưa có cuộc trò chuyện nào”.
- Loading: 4 shimmer rows.
- Prototype:
  - New message: tile tint primary 8% rồi fade 1.5s; badge pop 0→1.1→1.
  - On Tap: Navigate → Conversation (slide-left 200ms).
  - Swipe Left: reveal Mute/Pin buttons (Smart Animate, stagger 40ms).

### Conversation
- AppBar: back, avatar, name; nền Primary đậm (#065BEE). Body: background #7CCFF5 ở vùng chat, top radius 20.
- List message: bubbles mine/theirs, khoảng cách 4/2/4/12. Time và tick nhỏ góc dưới.
- Input bar: white, radius 20, prefix emoji, suffix attach, send (primary icon).
- Typing indicator: ba chấm nảy 2px, loop 900ms.
- Prototype:
  - Incoming bubble: slide từ trái 8px + fade 140ms.
  - Outgoing: slide từ phải 8px + fade.
  - Send button: rotate 25° 120ms, bubble mới expand height (spring).
  - Scroll-to-bottom FAB: fade+translateY 16px khi không ở đáy.

### Friends (Contact)
- List Tile với status text ở trailing. Empty state + loading state.
- Prototype: On tap → Account (profile người khác) slide-left 200ms.

### Profile (cá nhân)
- Collapsible header: cover (demo_background), avatar 80, tên, stats (Bạn bè/Nhóm).
- Section card: Accounts, Theme, Logout, mỗi mục ListTile có icon.
- Edit mode: toggle sang form (display name/email/phone) với crossfade và slide 8px.
- Logout: bottom sheet confirm (yes/no).

### News Feed
- Card: header avatar+name+time (relative “2h”), content text, 1 ảnh (full width radius 16), actions Like/Comment với counter.
- Comment: mở bottom sheet 70% cao, handle pill; danh sách comment; input dính đáy.
- Prototype:
  - Stagger list (60ms delay), slide-up 12px + fade 200ms.
  - Like: heart scale 0.9→1.2→1; counter nhảy lên 6px + fade.
  - Comment sheet: slide-up 24px + fade.

### Search
- AppBar: Search field với prefix search, suffix clear/spinner, radius 8. Background xám nhạt.
- Tabs: Segmented (Contact / Messages / Chat Room) với indicator.
- Result list: giống Tile; Empty state nếu không có kết quả.
- Prototype: debounce spinner quay 0.75 vòng/500ms trong suffix; tab change Smart Animate.

### Account (Profile người khác)
- Avatar + display name + status. Buttons: Kết bạn / Đã gửi / Chấp nhận / Nhắn tin.
- Popup actions nên chuyển thành bottom sheet (Block, Unfriend).
- Owner view: form cập nhật + đổi mật khẩu (2 trạng thái), dùng AnimatedOpacity.

## 4) Prototype links gợi ý
- Login → Hub (Messages) (On Tap Login success).
- Hub tabs: Smart Animate giữa 4 frames (Messages/Friends/Profile/Newsfeed).
- Messages item → Conversation; Conversation back → Messages.
- Friends item → Account; Account → Conversation (Nhắn tin).
- Newsfeed Comment → Bottom Sheet overlay.
- Search từ Hub action → Search frame; back bằng close.

## 5) Animation timing & easing
- Vi mô (focus, icon, like, badge): 120–180ms, easeOut / standard.
- Điều hướng trang: 200–280ms, easeOutQuad/standard.
- Pop/bounce: spring (tension ~300, damping ~25 nếu dùng plugin).

## 6) Cách dựng nhanh trên Figma
1. Tạo Page “Tokens”: lưu Color Styles, Text Styles, Effect (shadow), Radius.
2. Page “Components”: dựng các component và variants như trên.
3. Page “Screens”: clone component để ráp màn; bật Auto Layout cho list/card.
4. Prototype: Smart Animate giữa frame cùng layer name; bottom sheet dùng “Open overlay” vị trí bottom, backdrop blur 20–30%.
5. Tạo Flow start tại Login frame.

## 7) Mapping sang Flutter
- Page transition: `PageRouteBuilder` slide+fade.
- Micro animation: `AnimatedOpacity`, `AnimatedScale`, `AnimatedContainer`, `AnimatedSwitcher`.
- List: shimmer (package `shimmer`), cached image fadeIn (`cached_network_image`).
- Bottom sheet: `showModalBottomSheet` + `DraggableScrollableSheet`.
- Typing: `AnimationController` loop + `SlideTransition`.
- Like: `TweenSequence` scale 0.9→1.2→1 trong 140ms.

## 8) Xuất/nhập
- Bạn có thể copy các giá trị trên để dựng thủ công. Nếu muốn file .fig, hãy tạo khung theo checklist và đặt tên lớp trùng nhau để Smart Animate hoạt động (ví dụ: `card/message`, `avatar`, `title`, `subtitle`, `badge`, `bubble/mine`, `bubble/theirs`).

