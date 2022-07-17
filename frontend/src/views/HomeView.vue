<script lang="ts">
import Api from '../bridge/api'

export default{

  data() {
    return {
      loginData: {
        email: "",
        password: ""
      }
    }
  },

  async beforeMount() {
    const apiBridge = Api.getInstance();
    const res= await apiBridge.login("baroni.marco.91@gmail.com", "diocane")
    console.log(res, "daje")
    console.log("arriverò dopo?")
  },

  methods: {
    doLogin() {
    }
  }

};

</script>

<template>
  <main>
    <div class="login-page">
      <div class="container">
        <div class="row">
          <div class="col-lg-4 col-md-6 col-sm-8 mx-auto">
            <div class="card login">
              <h1>Log In</h1>
              <form class="form-group">
                <input v-model="loginData.email" type="email" class="form-control" placeholder="Email" required>
                <input v-model="loginData.password" type="password" class="form-control" placeholder="Password" required>
                <submit @click="doLogin">Accedi!</submit>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>