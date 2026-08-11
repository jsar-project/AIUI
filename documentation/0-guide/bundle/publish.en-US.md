# Publish to the Hi Rokid Agent Store

After you complete agent development and packaging (generating the `.aix` file), you can publish it to the Agent Store through the Rokid Rizon platform so that users worldwide can download and use it.

## 1. Log in to the AIUI Studio Global

Visit [AIUI Studio Global](https://aiui-global.rokid.com/space) and sign in with your developer account. If you do not have an account yet, complete registration and developer verification first.

## 2. Create an Agent Application

1. In the admin console, choose **"Application Management"** -> **"Create Application"**.
2. Select **"AIUI Agent"** as the application type.
3. Fill in the basic application information, including:
   - **Name**: The name displayed for the agent in the store.
   - **Icon**: A square icon that follows the design guidelines.
   - **Description**: A concise and clear introduction to the agent's features.

## 3. Upload the AIX Package

1. On the version management page, click **"Upload Version"**.
2. Upload the `.aix` file generated with the `aix pack` command.
3. The platform automatically validates the `VERSION` file and `AGENTS.md` declaration in the package.

## 4. Submit for Review

1. After confirming that the version information is correct, click **"Submit for Review"**.
2. The Rokid team reviews the agent's performance, interaction compliance, and security.
3. After approval, your agent is officially listed in the Hi Rokid Agent Store.

## 5. Update Versions

If you need to release new features or fix bugs:
1. Modify the code locally and run `aix pack` again.
2. Upload the new `.aix` file to the Rizon platform.
3. Submit the new version for review. After approval, user devices automatically trigger a hot update based on `VERSION`.
