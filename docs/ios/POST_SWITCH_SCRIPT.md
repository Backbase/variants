## Using Post Switch Script 

### What is a Post Switch Script?

Post Switch Script allows you to specify a script or command to run after switching variants. Here's what it does:

- **Variant-specific Post Switch Script**: You can define a script or command to run after switching to a particular variant.
- **Global Post Switch Script**: You can also define a script or command to run after switching to any variant globally.

If you specify both a variant-specific and a global postSwitchScript, the global one will run first, followed by the variant-specific one.

### How to use it

The "Post Switch Script" feature is optional for both local and global. In case you want to not use it you can simply omit the configuration in the `variants.yml` file.

#### **Adding a Post Switch Script to a Variant**:   - In your `variants.yml` file, add a `postSwitchScript` for a specific variant. For example:

   ```yaml
   variants:
     - name: variant1
       postSwitchScript: ./scripts/post_switch_variant1.sh
    ```

#### **Adding a global Post Switch Script**:
   - Add a global postSwitchScript to your variants.yml file. This script will run after switching to any variant. For example:

   ```yaml
       postSwitchScript: ./scripts/post_switch_variant1.sh
    ```

### Script vs. Command

The name "postSwitchScript" implies that you are providing a script to be run. However, in practice, you can also provide direct commands or the path to an executable bash file.

- **Direct Commands**: You can specify commands directly in the postSwitchScript field. For example for single-line script:
   ```yaml
    variants:
      - name: variant1
        postSwitchScript: echo "Hello, Variant 1"
   ```
   For example for multi-line script:
      ```yaml
    variants:
      - name: variant1
        postSwitchScript: >-
            echo "My first multi-command" && 
            echo "My second mulit-command"
   ```

- **Executable Bash File**: You can provide the path to an executable bash file. For example:
   ```yaml
    variants:
      - name: variant1
        postSwitchScript: my_post_switch_script.sh
   ```

### Additional Notes

- **Direct Execution of Files**: You can execute files by writing their path directly in the postSwitchScript field.
- **Multiple Commands**: If you want to execute multiple commands in the script, separate them using && (for sequential execution) or || (for conditional execution) at the end of each line.
- **Multi-Line Commands**: According to YAML specification, starting with |- is useful if you have multi-line commands or want to start a command on a new line for readability. Additionally, you should use >- instead of |- to strip the last \n.

That's it! You are now ready to make the most of the "Post Switch Script" feature for your configuration needs.
