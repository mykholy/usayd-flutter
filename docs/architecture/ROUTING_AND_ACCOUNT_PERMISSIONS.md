# USYD-T0080: Flutter Routing and Account Permissions Architecture
**Jira Key:** [USYD-73](https://mykholy.atlassian.net/browse/USYD-73)  
**External Task ID:** `USYD-T0080`  
**Candidate Sprint:** `S01`  
**Assignee:** Ahmed Mamdouh El-Sayed (`ahmedmmdouh9000@gmail.com`)  
**Authoritative Specifications:** `02_design_system/AGE_ADAPTIVE_UI.md`, `03_screens/SCREEN_INVENTORY.csv`, `DECISION_REQUIRED_FROM_OWNER.md` (O-04)

---

## 1. Executive Summary & Objective

The mobile application for Usayd Academy requires declarative navigation with robust route protection across multiple user dimensions:
1. **Authentication Boundary:** Unauthenticated requests redirect to `/login`; authenticated users on auth screens redirect to home.
2. **Age-Adaptive Shell Navigation:** Deeply integrated with `AdaptiveShell` supporting three distinct navigation models:
   - **Kids Mode (4 tabs):** `/app/mission`, `/app/path`, `/app/stars`, `/app/me`.
   - **Professional Mode (5 tabs):** `/app/home`, `/app/lessons`, `/app/recite`, `/app/progress`, `/app/profile`.
   - **Simple Mode (3 tabs):** `/app/today`, `/app/simple-lessons`, `/app/help`.
3. **Minor Protection Guards (O-04):** Users flagged as minors (`isMinor == true`) are restricted from financial and adult routes (`/app/billing`), redirecting safely to their home tab.
4. **Role-Based Access Control (RBAC):** Restricts teacher endpoints (`/teacher/*`) and admin endpoints (`/admin/*`) from unauthorized learner accounts, redirecting to `/unauthorized`.

---

## 2. Route Hierarchy & Configuration

```
RootNavigator
  │
  ├──► /splash (UX-MOBILE-000) [Public]
  ├──► /login (UX-AUTH-001) [Public]
  ├──► /register (UX-AUTH-002) [Public]
  ├──► /unauthorized [Public]
  │
  ├──► /teacher/room [Protected: Role = teacher/admin]
  ├──► /admin/settings [Protected: Role = admin]
  │
  └──► ShellRoute (RoutedAdaptiveShell) [Protected: Authenticated]
         ├── Pro Tabs:
         │     ├── /app/home
         │     ├── /app/lessons
         │     ├── /app/recite
         │     ├── /app/progress
         │     └── /app/profile
         ├── Kids Tabs:
         │     ├── /app/mission
         │     ├── /app/path
         │     ├── /app/stars
         │     └── /app/me
         ├── Simple Tabs:
         │     ├── /app/today
         │     ├── /app/simple-lessons
         │     └── /app/help
         └── Child-Restricted:
               └── /app/billing [Protected: isMinor == false]
```

---

## 3. Route Guard Enforcement Logic

Navigation redirects are evaluated synchronously by `RouteGuard.redirect`:
$$\text{Target} = \text{RouteGuard}(\text{location}, \text{isLoading}, \text{isAuthenticated}, \text{role}, \text{isMinor}, \text{mode})$$

1. **Loading State:** If `isLoading == true`, all navigation is held on `/splash`.
2. **Unauthenticated Access:** If `isAuthenticated == false` and `location \notin \text{PublicRoutes}`, redirect to `/login`.
3. **Redundant Auth Navigation:** If `isAuthenticated == true` and `location \in \{/\text{login}, /\text{register}, /\text{splash}\}`, redirect to `defaultRouteForMode(mode)`.
4. **Minor Protection:** If `isMinor == true` and `location \in \text{AdultOnlyRoutes}`, redirect to `defaultRouteForMode(mode)`.
5. **Role Check:** If `location.startsWith('/teacher')` and `role \notin \{\text{teacher}, \text{admin}\}`, redirect to `/unauthorized`.
6. **Admin Check:** If `location.startsWith('/admin')` and `role \neq \text{admin}`, redirect to `/unauthorized`.

---

## 4. Verification & Testing Matrix

The implementation is verified via unit and widget tests in `test/core/routing/app_router_test.dart`:
- `test_unauthenticated_user_redirected_to_login`
- `test_authenticated_user_on_login_redirected_to_pro_home`
- `test_authenticated_kids_mode_redirected_to_kids_mission`
- `test_minor_user_blocked_from_adult_billing_route`
- `test_learner_blocked_from_teacher_room`
- `test_teacher_allowed_in_teacher_room`
- `test_admin_allowed_in_admin_settings`
- `test_shell_tab_switching_triggers_correct_location`
